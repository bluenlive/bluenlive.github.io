---
layout: single
title: "윈도우에서도 tar를 쓸 수 있더라"
date: 2026-8-23 22:01:00 +0900
categories:
  - ITTalk
tags: []
---

## tar란 무엇인가
tar는 **Tape Archive**의 줄임말이다.\
본래 유닉스 시절 테이프 백업 장치에 데이터를 기록하기 위해 만들어졌다.\
핵심 역할은 파일들의 디렉터리 구조와 권한을 온전히 유지하며 하나로 '묶는(Archive)' 것이다.\
압축 기능은 없지만, gzip(`-z`)이나 bzip2(`-j`) 등을 연동해 아카이빙과 압축을 함께 처리하는 방식으로 널리 쓰인다.

## 윈도우에선 언제부터 쓸 수 있었을까?
**Windows 10 빌드 17063(버전 1803)**부터 기본 탑재되었다.\
`System32` 폴더에 `tar.exe`가 내장되어 있어 별도의 서드파티 압축 프로그램 없이도 명령줄에서 즉시 쓸 수 있다.\
내부적으로는 오픈소스 `bsdtar` 엔진을 사용한다.

## 간단한 tar 묶기 및 압축 예제
상대 경로를 깔끔하게 유지하려면 `-C` 옵션으로 대상 디렉터리로 먼저 이동한 뒤 `.`(현재 위치)을 지정하는 것이 좋다.

* **압축 없이 묶기:**

```dos
tar -cvf archive.tar -C "C:\target_folder" .
```

* **gzip으로 압축하며 묶기:**

```dos
tar -czvf archive.tar.gz -C "C:\target_folder" .
```

## 내용 확인과 압축 풀기

* **내용 목록만 미리 보기 (압축 해제 X):**

```dos
tar -tf archive.tar.gz
```

* **원하는 폴더에 압축 풀기:**

```dos
tar -xzvf archive.tar.gz -C "C:\extract_folder"
```

*(무압축 `.tar` 파일이라면 `-xvf`를 사용한다.)*

## 대용량 파일을 3.5GiB 단위로 분할하고 합치기
FAT32 파일 시스템의 4GiB 단일 파일 제한을 피하기 위해 대용량 아카이브를 분할해야 할 때가 있다.\
윈도우엔 리눅스의 `split` 명령이 없고 파워셸(PowerShell)을 활용해 바이너리 스트림으로 쪼개고 합칠 수 있다.

* **3.5GiB 단위로 분할하기:**

```powershell
$src = "archive.tar.gz"; $chunk = [int64]3.5 * 1GB; $buf = New-Object byte[] (64*1024*1024); $i = 1
$fs = [System.IO.File]::OpenRead($src)
try {
    while ($fs.Position -lt $fs.Length) {
        $out = [System.IO.File]::Create(("{0}.part{1:D3}" -f $src, $i++))
        try {
            $w = 0
            while ($w -lt $chunk -and $fs.Position -lt $fs.Length) {
                $r = $fs.Read($buf, 0, [Math]::Min($buf.Length, $chunk - $w))
                $out.Write($buf, 0, $r); $w += $r
            }
        } finally { $out.Dispose() }
    }
} finally { $fs.Dispose() }
```

* **순서대로 병합한 뒤 압축 풀기:**\
바이너리 파일이므로 파일 이름 순서(part001, part002...)를 정렬하여 합쳐야 데이터가 깨지지 않는다.

```powershell
# 1. 파일 이름 순서대로 정렬하여 병합
$dest = [System.IO.File]::Create("combined.tar.gz")
try {
    Get-ChildItem "archive.tar.gz.part*" | Sort-Object Name | ForEach-Object {
        $part = [System.IO.File]::OpenRead($_.FullName)
        try { $part.CopyTo($dest) } finally { $part.Dispose() }
    }
} finally { $dest.Dispose() }

# 2. 압축 해제
tar -xzvf combined.tar.gz -C "C:\extract_folder"
```
