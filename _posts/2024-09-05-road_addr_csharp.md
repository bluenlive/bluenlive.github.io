---
layout: single
title: "C#에서 도로명 주소 검색 서비스 개발하기"
categories:
  - algorithm
---

**도로명 주소**를 검색하는 서비스는 흔하게 볼 수 있다.  
이제 국가주소정보시스템 자체가 안정화되어 도로명 주소 검색을 웹에서 개발하는 것은 어렵지 않다.  
예제 코드도 공개되어 있어서, 그대로 사용하면 된다.

**C#**에서 이 서비스를 활용하는 방법을 간단하게 정리해본다.

## API 키 발급

이 서비스를 사용하기 위해서는 API 키가 필요하다.  
국가주소정보시스템에서 API 키를 발급받아야 한다.

[국가주소정보시스템 API신청하기](https://business.juso.go.kr/addrlink/openApi/apiReqst.do){:target="_blank"}에 접속해서 API 키를 발급받는다.  
이 때 반드시 **검색API**를 신청해야 한다.

![image](/images/2024-09-05/apis64_Q.png){: .align-center}
*검색API*

페이지 하단에서는 아래와 같은 경고를 볼 수 있다.  
당연한 말씀.

![image](/images/2024-09-05/law_Bs64_Q.png){: .align-center}

## WinForm 프로젝트 생성

간단하게 WinForm 프로젝트를 생성한다.  
아래와 같이 만들면 되며, 간단하게 결과를 볼 수 있도록 **DataGridView**를 사용한다.

![image](/images/2024-09-05/winform_Q.png){: .align-center}
*회색 박스가 DataGridView*

## API 호출

우선, 필요한 라이브러리를 추가한다.

```csharp
using System.Data;
using System.Text.RegularExpressions;
using System.Xml;
```

그리고는 버튼 클릭 이벤트를 만들어서 아래와 같이 코드를 작성한다.

```csharp
private async void btSearch_Click(object sender, EventArgs e)
{
    string confmKey = "발급 받은 인증키";
    string keyword = tbKeyword.Text.Trim();

    string apiurl = "https://www.juso.go.kr/addrlink/addrLinkApi.do?confmKey=" + confmKey + "&currentPage=1&countPerPage=500&keyword=" + keyword + "&confmKey=" + confmKey;
    tbURL.Text = apiurl;

    using HttpClient client = new();
    using HttpResponseMessage response = await client.GetAsync(apiurl);
    response.EnsureSuccessStatusCode();
    using Stream stream = await response.Content.ReadAsStreamAsync();

    XmlReader read = new XmlTextReader(stream);
    lvAddr.Items.Clear();

    DataSet ds = new();
    ds.ReadXml(read);

    DataRow[] dr = ds.Tables[0].Select();
    int totalCount = int.Parse(dr[0]["totalCount"]?.ToString() ?? "0");
    string errorMessage = dr[0]["errorMessage"]?.ToString() ?? string.Empty;

    if (totalCount > 0)
        dgvResult.DataSource = ds.Tables[1];
    else
    {
        if (errorMessage != "정상")
            MessageBox.Show(text: errorMessage, caption: "Error", buttons: MessageBoxButtons.OK, icon: MessageBoxIcon.Error);
        else
            MessageBox.Show("검색 결과가 없습니다.");
    }
}
```

## 결과

이렇게 하면, 간단하게 도로명 주소 검색 서비스를 만들 수 있다.  
검색 결과는 아래 보는 것처럼 나타난다.

![image](/images/2024-09-05/result_Q.png){: .align-center}

## One More Thing

그런데, 이것만으로는 뭔가 살짝 부족하다.  
**부적절한 접속을 방지**하기 위한 **보호 코드**를 추가하는 것이 좋으며, 이는 예제 코드에도 명시되어 있다.

![image](/images/2024-09-05/sample_Q.png){: .align-center}
*정규식 13회 실행의 압박*

그런데, 이 코드를 들여다 보면 뭔가 이상하다.  
위의 정규식 코드로는 **\[**, **\]** 를 걸러낼 수 없다.  
그런데, 가이드를 보면 **\[**, **\]** 는 검색이 불가하다고 명시되어 있다.

![image](/images/2024-09-05/error_Q.png){: .align-center}
*\[, \] 도 검색이 불가하다고 명시되어 있음*

게다가, **SELECT** 처럼 SQL Injection을 막기 위한 코드 부분은 단순하게 해당 단어만 들어있으면 무조건 걸러낸다.  
그리고, 그 단어 중에 **OR**이 포함되어 있다.  
따라서, **WORLD** 같은 단어도 검색할 수 없는 것이다.

모든 단어에 대해 일일이 정규식을 반복 수행해서 **비효율적**인 것은 덤이다.

아래와 같이 코드를 작성하면 정규식 하나로 모든 것을 처리할 수 있다.  
C#에서는 실행 효율을 위해 **컴파일된 정규식**을 사용하는 것이 좋다.

```csharp
[GeneratedRegex(@"[\[\]%=><]|\b(OR|SELECT|INSERT|DELETE|UPDATE|CREATE|DROP|EXEC|UNION|FETCH|DECLARE|TRUNCATE)\b", RegexOptions.IgnoreCase)]
private static partial Regex MyRegexInvalidChar();

private static string CheckInvalidChars(string text)
{
    Match ret = MyRegexInvalidChar().Match(text);
    if (!ret.Success)
        return string.Empty;

    return (ret.Value.Length < 3) ? ret.Value : ret.Value[1..^1];
}
```
