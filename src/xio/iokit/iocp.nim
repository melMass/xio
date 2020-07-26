{.pragma: libKernel32, stdcall, dynlib: "Kernel32.dll".}
{.pragma: libWs2_32, stdcall, dynlib: "Ws2_32.dll".}


type
  Handle* = int
  DWORD* = int32
  PDWORD* = ptr DWORD
  LPDWORD* = ptr DWORD
  LPINT* = ptr int32
  ULONG* = int32
  ULONG_PTR* = uint
  PULONG_PTR* = ptr uint
  HDC* = Handle
  HGLRC* = Handle
  PVOID* = pointer
  LPVOID* = pointer

  WINBOOL = int32 ## if WINBOOL != 0, it succeeds which is different from posix.

  OVERLAPPED_offset* = object
    offset*: DWORD
    offsetHigh*: DWORD

  OVERLAPPED_union* {.union.} = object
    offset*: OVERLAPPED_offset
    p*: PVOID

  OVERLAPPED* = object
    internal*: ULONG_PTR
    internalHigh*: ULONG_PTR
    union*: OVERLAPPED_union
    hevent*: Handle

  LPOVERLAPPED* = ptr OVERLAPPED


  WSAOVERLAPPED* = object
    internal*: ULONG_PTR
    internalHigh*: ULONG_PTR
    offset*: DWORD
    offsetHigh*: DWORD
    hevent*: Handle

  LPWSAOVERLAPPED* = ptr WSAOVERLAPPED

  LPWSAOVERLAPPED_COMPLETION_ROUTINE* = proc (dwError: DWORD, cbTransferred: DWORD, 
                                             lpOverlapped: LPWSAOVERLAPPED, dwFlags: DWORD)

  WSABUF* = object
    len*: ULONG
    buf*: cstring

  LPWSABUF* = ptr WSABUF

  SocketHandle* = distinct int


const
  INVALID_HANDLE_VALUE = -1

proc createIoCompletionPort*(FileHandle: Handle, ExistingCompletionPort: Handle,
  CompletionKey: ULONG_PTR, NumberOfConcurrentThreads: DWORD
): Handle {.libKernel32, importc: "CreateIoCompletionPort"}
  ## Creates an input/output (I/O) completion port and associates it with a specified file handle.

proc getQueuedCompletionStatus*(CompletionPort: Handle,
  lpNumberOfBytesTransferred: LPDWORD,
  lpCompletionKey: PULONG_PTR,
  lpOverlapped: LPOVERLAPPED,
  dwMilliseconds: DWORD
): WinBool {.libKernel32, importc: "GetQueuedCompletionStatus"}

proc closeHandle*(hObject: Handle): WINBOOL {.libKernel32,
    importc: "CloseHandle".}

proc WSAIoctl*(s: SocketHandle; dwIoControlCode: DWORD; lpvInBuffer: LPVOID;
  cbInBuffer: DWORD; lpvOutBuffer: LPVOID; cbOutBuffer: DWORD;
  lpcbBytesReturned: LPDWORD; lpOverlapped: LPOVERLAPPED;
  lpCompletionRoutine: LPWSAOVERLAPPED_COMPLETION_ROUTINE
): cint {.libWs2_32, importc: "WSAIoctl".}

proc WSARecv*(
  s: SocketHandle,
  lpBuffers: LPWSABUF,
  dwBufferCount: DWORD,
  lpNumberOfBytesRecvd: LPDWORD,
  lpFlags: LPDWORD,
  lpOverlapped: LPWSAOVERLAPPED,
  lpCompletionRoutine: LPWSAOVERLAPPED_COMPLETION_ROUTINE
): cint {.libWs2_32, importc: "WSARecv".}

proc WSAGetLastError*(): cint {.libWs2_32, importc: "WSAGetLastError".}

when isMainModule:
  echo createIoCompletionPort(INVALID_HANDLE_VALUE, 0, 0, 1)
