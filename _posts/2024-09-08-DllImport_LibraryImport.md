---
layout: single
title: "C#에서 DllImport 대신 LibraryImport 사용하기"
date: 2024-9-8 15:58:00 +0900
categories:
  - algorithm
---

C# 만으로는 모든 기능을 구현할 수 없기 때문에 윈도우 등에서 만든 DLL을 사용해야 할 때가 있다.  
이를 위해 `DllImport`를 사용하는데, .NET 5부터는 `DllImport` 대신 `LibraryImport`를 사용할 수 있다.

`DllImport`는 마샬링을 **런타임**에서 수행하므로, 동적으로 IL 코드를 생성할 수 없는 환경에서는 사용할 수 없었다.  
`LibraryImport`는 **컴파일 시점**에서 마샬링 코드를 생성하기 때문에 이러한 문제를 해결할 수 있다.

## GetSystemMenu

`DllImport`는 아래와 같이 간단하게 사용한다.

```csharp
[DllImport("user32.dll")]
private static extern IntPtr GetSystemMenu(IntPtr hWnd, bool bRevert);
```

이를 `LibraryImport`로 변경하면 아래와 같다.

```csharp
[LibraryImport("user32.dll")]
private static partial IntPtr GetSystemMenu(IntPtr hWnd, [MarshalAs(UnmanagedType.Bool)] bool bRevert);
```

쉽게 생각하면 `extern` 대신 `partial` 키워드를 사용하며, 필요한 경우 `MarshalAs` 특성을 사용하면 된다.

## AppendMenu

`AppendMenu` 처럼 문자열을 전달하는 경우는 좀 더 상세한 기술이 필요하다.  
Win32에서는 **멀티바이트**와 **유니코드**를 구분해서 전달해야 하기 때문이다.

`DllImport`를 사용할 때는 적당히 사용하면 됐다.

```csharp
[DllImport("user32.dll")]
private static extern bool AppendMenu(IntPtr hMenu, Int32 wFlags, Int32 wIdNewItem, string lpNewItem);
```

하지만, `LibraryImport`를 사용할 때는 조금 더 신경을 써야 한다.  
`string`을 런타임에 적절히 처리하기 않기 때문에 사전에 정확한 내용들을 기술해야 한다.  
또한, **진입점** 역시 정확하게 지정해야 한다.

```csharp
[LibraryImport("user32.dll", EntryPoint = "AppendMenuW", StringMarshalling = StringMarshalling.Utf16)]
[return: MarshalAs(UnmanagedType.Bool)]
private static partial bool AppendMenu(IntPtr hMenu, Int32 wFlags, Int32 wIdNewItem, string lpNewItem);
```
