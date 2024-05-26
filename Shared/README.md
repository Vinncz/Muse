#  Shared

The folder which contains shared piece of code, that are used by both Muse of iOS and WatchOS.

### Declaration and Extensions Index

If there exists a class, which is extended in more than one file, the following map might give you a hint on where to find the declaration and the extensions.
```
Class:
WorkoutManager

Shared/
|
|- Extensions/
|  |
|  |- WorkoutManager.swift
|  |- WorkoutManager_iOS.swift
|  |- WorkoutManager_watchOS.swift
|
|- HealthKit/
   |
   |- WorkoutManager.swift (Declaration)
```
