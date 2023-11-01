#!/usr/bin/env python

import argparse
import asyncio
import functools
import logging
import sys

from dbus_next.aio import MessageBus
from dbus_next.constants import BusType

PREFIX = '\ue00b '

endpoints = set()
devices = []


class Device:
    def __init__(self, path, name, connected=False, battery=None, volume=None):
        # Strip LE_ prefix
        if name.startswith('LE_'):
            name = name[3:]
        self.path = path
        self.name = name
        self.connected = connected
        self.battery = battery
        self.volume = volume

    def __repr__(self):
        return '<Device({!r}, {!r})>'.format(self.path, self.name)

    def __str__(self):
        s = self.name
        if self.battery:
            icon = chr(0xe030 + min(self.battery, 99) // 25)
            s += f' {icon} {self.battery}%'
        if self.volume:
            s += f' \ue05d {self.volume * 100 // 128}%'
        return s


def find_device(path, prefix=False):
    for d in devices:
        if path.startswith(d.path) if prefix else d.path == path:
            return d


def on_added(path, interfaces):
    logger.debug('on_added %r %r', path, interfaces)
    if 'org.bluez.MediaEndpoint1' in interfaces:
        logger.debug('connected: %s', path)
        endpoints.add(path)
    if battery := interfaces.get('org.bluez.Battery1'):
        if device := find_device(path):
            device.battery = battery['Percentage'].value
            if device.connected:
                print(f'{PREFIX}{device}', file=sys.stderr)
    if mt := interfaces.get('org.bluez.MediaTransport1'):
        if device := find_device(path, True):
            asyncio.create_task(setup_device(device, path))


def on_removed(path, interfaces):
    logger.debug('on_removed %r %r', path, interfaces)
    if path in endpoints:
        logger.debug('disconnected: %s', path)
        endpoints.discard(path)


def on_name_owner_changed(name, old_owner, new_owner):
    # print('on_name_owner_changed', name, old_owner, new_owner)
    if name == 'org.bluez':
        if new_owner:
            logger.debug('bluez has started')
            bluez_ready.set()
        else:
            logger.debug('bluez has stopped')
            bluez_ready.clear()


def on_adapter_properties_changed(name, changed_properties, invalidated_properties):
    logger.debug('on_adapter_properties_changed %r %r %r', name, changed_properties, invalidated_properties)
    powered = changed_properties.get('Powered')
    if powered is None:
        return
    powered = powered.value
    if powered:
        print(f'{PREFIX}not connected', file=sys.stderr)
    else:
        print(f'{PREFIX}off', file=sys.stderr)


async def setup_device(device, mt_path):
    introspection = await bus.introspect('org.bluez', device.path)
    obj = bus.get_proxy_object('org.bluez', device.path, introspection)
    interface = obj.get_interface('org.freedesktop.DBus.Properties')
    interface.on_properties_changed(functools.partial(on_device_properties_changed, device))

    introspection = await bus.introspect('org.bluez', mt_path)
    obj = bus.get_proxy_object('org.bluez', mt_path, introspection)
    interface = obj.get_interface('org.freedesktop.DBus.Properties')
    interface.on_properties_changed(functools.partial(on_device_properties_changed, device))


def on_device_properties_changed(device, name, changed_properties, invalidated_properties):
    logger.debug('on_device_properties_changed %r %r %r %r', device, name, changed_properties, invalidated_properties)
    if (connected := changed_properties.get('Connected')) is not None:
        device.connected = connected.value
        #if device.connected:
        #    asyncio.create_task(setup_device(device.path))
    if (volume := changed_properties.get('Volume')) is not None:
        device.volume = volume.value
    if name == 'org.bluez.Battery1' and (battery := changed_properties.get('Percentage')) is not None:
        device.battery = battery.value
    if not device.connected:
        device = next((d for d in devices if d.connected), None)
    if device and device.connected:
        print(f'{PREFIX}{device}', file=sys.stderr)
    else:
        print(f'{PREFIX}not connected', file=sys.stderr)


async def setup_bluez(bus):
    global devices, bluez_introspection
    logger.debug('setup bluez')
    introspection = await bus.introspect('org.bluez', '/')
    obj = bus.get_proxy_object('org.bluez', '/', introspection)
    om = obj.get_interface('org.freedesktop.DBus.ObjectManager')
    om.on_interfaces_added(on_added)
    om.on_interfaces_removed(on_removed)
    objects = await om.call_get_managed_objects()
    devices = []
    path = None
    powered = False
    mt_device = None
    for k, v in objects.items():
        if adapter := v.get('org.bluez.Adapter1'):
            path = k
            # logger.debug(adapter)
            powered = adapter['Powered'].value
        if device := v.get('org.bluez.Device1'):
            if battery := v.get('org.bluez.Battery1'):
                battery = battery.get('Percentage').value
            # logger.debug(device)
            name = device['Name'].value
            alias = device.get('Alias')
            if alias and alias.value:
                name = alias.value
            devices.append(Device(k, name, connected=device.get('Connected').value, battery=battery))
        if mt := v.get('org.bluez.MediaTransport1'):
            mt_device = mt['Device'].value
            # logger.debug('MediaTransport1 %s %s', k, mt)
            devices[-1].media_transport = k
            devices[-1].volume = mt.get('Volume').value
    if path:
        introspection = await bus.introspect('org.bluez', path)
        obj = bus.get_proxy_object('org.bluez', path, introspection)
        interface = obj.get_interface('org.freedesktop.DBus.Properties')
        interface.on_properties_changed(on_adapter_properties_changed)
    else:
        logger.warning('No path found for adapter')
    for device in devices:
        obj = bus.get_proxy_object('org.bluez', device.path, introspection)
        # logger.debug('%s', obj)
        interface = obj.get_interface('org.freedesktop.DBus.Properties')
        interface.on_properties_changed(functools.partial(on_device_properties_changed, device))
        if mt_device := getattr(device, 'media_transport', None):
            obj = bus.get_proxy_object('org.bluez', mt_device, introspection)
            interface = obj.get_interface('org.freedesktop.DBus.Properties')
            interface.on_properties_changed(functools.partial(on_device_properties_changed, device))
    # print(dir(interface))
    # await interface.call_add_match("type='signal',path='{}',interface='org.freedesktop.DBus.Properties',"
    #                                "member='PropertiesChanged',arg0='org.bluez.Adapter1'")
    if powered:
        for device in devices:
            if device.connected:
                print(f'{PREFIX}{device}', file=sys.stderr)
                break
        else:
            print(f'{PREFIX}not connected', file=sys.stderr)
    else:
        print(f'{PREFIX}off', file=sys.stderr)
    # print(devices['/org/bluez'])
    # obj = bus.get_proxy_object('org.bluez', '/org/bluez/hci0', introspection)
    # adapter = obj.get_interface('org.bluez.Adapter1')
    # print(dir(adapter))

    # org.bluez /org/bluez/hci0 org.freedesktop.DBus.Properties Set 
    #   org.bluez.Adapter1
    #   Powered
    #   true

    # PropertiesChanged


async def setup_watcher(bus):
    print(f'{PREFIX}off', file=sys.stderr)
    logger.info('setup dbus watcher')
    introspection = await bus.introspect('org.freedesktop.DBus', '/org/freedesktop/DBus')
    obj = bus.get_proxy_object('org.freedesktop.DBus', '/org/freedesktop/DBus', introspection)
    interface = obj.get_interface('org.freedesktop.DBus')
    await interface.call_add_match("type='signal',sender='org.freedesktop.DBus',path='/org/freedesktop/DBus',"
                                   "interface='org.freedesktop.DBus',member='NameOwnerChanged',arg0='org.bluez'")
    interface.on_name_owner_changed(on_name_owner_changed)
    names = await interface.call_list_names()
    if 'org.bluez' in names:
        bluez_ready.set()


async def main():
    global bus
    bus = await MessageBus(bus_type=BusType.SYSTEM).connect()
    await setup_watcher(bus)
    await bluez_ready.wait()
    await setup_bluez(bus)
    await bus.wait_for_disconnect()


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('-v', '--verbose', help='Enable logging', action='store_true')
    return parser.parse_args()


args = parse_args()

logger = logging.getLogger()
logger.setLevel(logging.DEBUG)
if args.verbose:
    logging.basicConfig(level=logging.DEBUG)
else:
    logging.getLogger().addHandler(logging.NullHandler())
bluez_ready = asyncio.Event()
loop = asyncio.new_event_loop()
asyncio.set_event_loop(loop)
loop.run_until_complete(main())
