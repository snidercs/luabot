# SPDX-FileCopyrightText: Michael Fisher @mfisher31
# SPDX-License-Identifier: MIT

import os,time
from pathlib import Path

from watchdog.observers import Observer
from watchdog.events import PatternMatchingEventHandler
from subprocess import call

def touch_meson_build():
    Path('meson.build').touch()
    call('meson compile -C build'.split())
    print ("[watch] Meson rebuild done!")

def on_created(event):
    print(f"[watch] created: {event.src_path}")
    touch_meson_build()

def on_deleted(event):
    print(f"[watch] deleted: {event.src_path}!")
    touch_meson_build()

def on_modified(event):
    print(f"[watch] changed: {event.src_path}")
    touch_meson_build()

def on_moved(event):
    print(f"[watch] moved: {event.src_path} -> {event.dest_path}")
    touch_meson_build()

if __name__ == "__main__":
    patterns = ["*.*"]
    ignore_patterns = None
    ignore_directories = False
    case_sensitive = True

    my_event_handler = PatternMatchingEventHandler(patterns, ignore_patterns, ignore_directories, case_sensitive)
    my_event_handler.on_created = on_created
    my_event_handler.on_deleted = on_deleted
    my_event_handler.on_modified = on_modified
    my_event_handler.on_moved = on_moved

    path = os.path.abspath('bindings')
    go_recursively = True

    my_observer = Observer()
    my_observer.schedule(my_event_handler, path, recursive=go_recursively)
    my_observer.start()

    print ("Watching bindings directory for changes")
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        my_observer.stop()
        my_observer.join()

