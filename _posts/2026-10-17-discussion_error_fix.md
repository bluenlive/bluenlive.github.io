---
layout: single
title: "깃허브 블로그 댓글 문제 해결"
date: 2026-10-17 08:07:00 +0900
categories:
  - blog
---

본 블로그는 [깃허브](https://github.com)의 **깃허브 페이지** 서비스에서 돌아간다.\
댓글 서비스는 [giscus](https://giscus.app)를 활용해서 `Discussions`를 댓글로 활용한다.

최근 좀 바빠서 블로그에 큰 신경을 못 썼는데, 정신을 차려보니 블로그 댓글들이 보이지 않았다.

![image](/images/2026-10-17/github1_okl_s36_Q.webp)
*내 댓글 다 어디 감?*

블로그 및 댓글 설정을 전면 확인했으나, 설정은 정상이었고 많은 댓글이 **잠금 상태**로 빠진 것을 확인했다.\
많은 테스트 결과 두 가지 작업을 하면 모든 댓글이 정상이 된다는 점을 확인했다.

{: .bluebox-blue}
1. 깃허브의 모든 `Discussions` 항목들의 **잠금을 해제**
2. `Discussions`의 모든 항목들을 **카테고리를 다른 곳으로 이동했다 원복**
   - 이게 좀 웃긴데, 1번 만으로는 깃허브 시스템이 목록을 **갱신하지 않기** 때문

그런데, 이 작업을 수작업으로 일일이 하려면 너무나 귀찮다.\
그래서, `workflow`에 작업을 등록했다.

```yaml
name: Discussions 복구 및 재색인

on:
  workflow_dispatch: # 웹에서 수동 실행 버튼 활성화

permissions:
  discussions: write
  contents: read

jobs:
  repair-and-reindex:
    name: 잠금 해제 및 카테고리 재색인
    runs-on: ubuntu-latest
    steps:
      - name: Discussions 순회 및 일괄 복구 실행
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          REPO: ${{ github.repository }}
        run: |
          echo "==> 저장소 카테고리 및 Discussion 목록 조회 중..."
          
          # 1. Announcements 및 General 카테고리 ID, Discussion 목록 가져오기
          DATA=$(gh api graphql -f query='
            query($owner: String!, $name: String!) {
              repository(owner: $owner, name: $name) {
                discussionCategories(first: 10) {
                  nodes { id name }
                }
                discussions(first: 100) {
                  nodes {
                    id
                    number
                    title
                    locked
                    category { id name }
                  }
                }
              }
            }' -F owner="${REPO%/*}" -F name="${REPO#*/}")

          ANN_ID=$(echo "$DATA" | jq -r '.data.repository.discussionCategories.nodes[] | select(.name=="Announcements") | .id')
          GEN_ID=$(echo "$DATA" | jq -r '.data.repository.discussionCategories.nodes[] | select(.name=="General") | .id')

          echo "Target Category (Announcements) ID: $ANN_ID"
          echo "Temp Category (General) ID: $GEN_ID"

          # 2. 모든 Discussion 순회
          echo "$DATA" | jq -c '.data.repository.discussions.nodes[]' | while read -r item; do
            ID=$(echo "$item" | jq -r '.id')
            NUM=$(echo "$item" | jq -r '.number')
            TITLE=$(echo "$item" | jq -r '.title')
            LOCKED=$(echo "$item" | jq -r '.locked')
            CAT_NAME=$(echo "$item" | jq -r '.category.name')

            echo "--------------------------------------------------"
            echo "Discussion #${NUM}: ${TITLE}"

            # 1단계: 잠겨 있는 경우 Unlock 실행
            if [ "$LOCKED" = "true" ]; then
              echo " -> 잠금 상태 감지: Unlock 실행 중..."
              gh api graphql -f query='
                mutation($id: ID!) {
                  unlockLockable(input: { lockableId: $id }) {
                    unlockedRecord { ... on Discussion { locked } }
                  }
                }' -F id="$ID" > /dev/null
              echo " -> 잠금 해제 완료"
            else
              echo " -> 이미 열려 있음 (Locked 아님)"
            fi

            # 2단계: Announcements 글이면 General로 이동 후 다시 Announcements로 복귀 (강제 색인 갱신)
            if [ "$CAT_NAME" = "Announcements" ] && [ -n "$GEN_ID" ] && [ -n "$ANN_ID" ]; then
              echo " -> 색인 재가동: General 카테고리로 임시 이동..."
              gh api graphql -f query='
                mutation($id: ID!, $catId: ID!) {
                  updateDiscussion(input: { discussionId: $id, categoryId: $catId }) {
                    discussion { number }
                  }
                }' -F id="$ID" -F catId="$GEN_ID" > /dev/null

              sleep 1

              echo " -> Announcements 카테고리로 복귀..."
              gh api graphql -f query='
                mutation($id: ID!, $catId: ID!) {
                  updateDiscussion(input: { discussionId: $id, categoryId: $catId }) {
                    discussion { number }
                  }
                }' -F id="$ID" -F catId="$ANN_ID" > /dev/null
              echo " -> 색인 갱신 완료"
            fi

            sleep 1 # API 호출 제한 방지
          done

          echo "--------------------------------------------------"
          echo "모든 Discussion의 잠금 해제 및 색인 재가동 작업 완료"
```

이렇게 만들어진 워크플로우를 일단 실행.

![image](/images/2026-10-17/github2_okl_s36_Q.webp)
*어때요... 가슴이 두근거리지 않나요?*

그리고는 짜잔!\
댓글들이 복원되었다!!!

![image](/images/2026-10-17/github3_okl_s36_Q.webp)

그런데, 복원된 목록을 다시 읽어보니 문제가 좀 있었다.\
댓글이 잠기면 **해당 댓글 목록은 비활성화** 되는데, 그 때 다시 댓글을 달면 **새로운 댓글이 생성**된다.

이렇게 중복된 댓글이 세 세트나 있는 경우가 있었다.\
그리고, 이런 경우에는 **깃허브엔 이 세트들을 병합하는 기능 따윈 없다**.\
하나만 선택하고 나머지는 **버려야 한다**. ㅠㅠ

![image](/images/2026-10-17/github4_okl_s36_Q.webp)

이런 작업을 마친 결과 정상적으로 댓글이 돌아왔다.

![image](/images/2026-10-17/github5_okl_s36_Q.webp)
