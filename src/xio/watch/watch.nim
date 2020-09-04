import timerwheel
import os, base
export base


when defined(windows):
  import windir, filepoll
  export windir, filepoll


type
  Watcher* = object
    timer: Timer

proc taskCounter*(watcher: Watcher): int =
  watcher.timer.wheel.taskCounter

when false:
  proc isEmpty*(data: DirEventData): bool
  iterator events*(data: DirEventData): PathEvent
  proc close*(data: FileEventData)

  proc isEmpty*(data: FileEventData): bool
  iterator events*(data: DirEventData): PathEvent
  proc close*(data: DirEventData)

proc initWatcher*(interval = 100): Watcher =
  result.timer = initTimer(interval)

proc register*(watcher: var Watcher, data: var FileEventData, ms = 10, repeatTimes = -1) =
  var event = initTimerEvent(filecb, cast[pointer](addr data))
  data.node = watcher.timer.add(event, ms, repeatTimes)

proc register*(watcher: var Watcher, data: var DirEventData, ms = 10, repeatTimes = -1) =
  var event = initTimerEvent(dircb, cast[pointer](addr data))
  data.node = watcher.timer.add(event, ms, repeatTimes)

proc register*(watcher: var Watcher, dataList: var seq[FileEventData], ms = 10, repeatTimes = -1) =
  for data in dataList.mitems:
    var event = initTimerEvent(filecb, cast[pointer](addr data))
    data.node = watcher.timer.add(event, ms, repeatTimes)

proc register*(watcher: var Watcher, dataList: var seq[DirEventData], ms = 10, repeatTimes = -1) =
  for data in dataList.mitems:
    var event = initTimerEvent(dircb, cast[pointer](addr data))
    data.node = watcher.timer.add(event, ms, repeatTimes)

proc remove*(watcher: var Watcher, data: FileEventData | DirEventData) =
  watcher.timer.cancel(data.node)
  data.close()

proc poll*(watcher: var Watcher, ms = 100) =
  sleep(ms)
  discard process(watcher.timer)


when isMainModule:
  block:
    var count = 0
    proc hello(event: PathEvent) =
      inc count

    let filename = "d://qqpcmgr/desktop/e.txt"
    var data = initFileEventData(filename, cb = hello)
    var watcher = initWatcher(1)
    register(watcher, data)

    writeFile(filename, "123")
    poll(watcher, 10)

    doAssert watcher.taskCounter == 1
    doAssert count == 1

    moveFile(filename, "d://qqpcmgr/desktop/1223.txt")
    poll(watcher, 10)
    doAssert watcher.taskCounter == 1
    doAssert count == 2

    remove(watcher, data)
    poll(watcher, 10)
    doAssert watcher.taskCounter == 0
    doAssert count == 2

  block:
    let path = "d://qqpcmgr/desktop/test"
    var data = initDirEventData(path)
    var watcher = initWatcher(100)
    register(watcher, data)

    while true:
      poll(watcher, 2000)
      echo data.getEvent()
