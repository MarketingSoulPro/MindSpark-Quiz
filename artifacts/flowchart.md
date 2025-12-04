# MindSpark — Flowchart & State Machine (Textual + Transition Map)

Overview
- The flowchart below describes user states and transitions for the main user journey. Each arrow includes trigger and validations.

Legend
- [STATE] ---action/trigger---> [NEXT STATE] (conditions /side-effects)

Flow start: Entry
- [Entry] --open plugin page--> [Welcome / Age Selection]
  - Side-effects: load available age groups via GET /age-groups

Age selection
- [Welcome / Age Selection]
  - User action: selectAge(ageId)
  - Validation: ageId must correspond to an age group
  - On success:
    - persist selection (user session/localStorage)
    - fetch topics: GET /topics?ageGroup=ageId
    - navigate -> [Topic Selection]

Topic selection
- [Topic Selection]
  - User action: selectTopic(topicId)
  - Validation:
    - topic exists and topic.ageGroup == selectedAge
    - topic.questionsCount > 0 else tile disabled
  - On success:
    - persist topic selection
    - fetch levels: GET /levels?topic=topicId&page=1
    - navigate -> [Level Selection]
  - Back action: back() -> [Welcome / Age Selection]
  - Dashboard action: goDashboard() -> [Dashboard]

Level selection (per topic)
- [Level Selection]
  - Data: levels 1..N with status (locked/unlocked/completed)
  - User actions:
    - clickLevel(levelId)
      - If locked -> show modal: "Locked: complete Level X"
      - If unlocked -> navigate -> [Quiz Start]
    - paginate(page) -> load page
  - Preconditions:
    - levels 1-3 unlocked by default
    - level N+1 locked until level N completed (>=70%)
  - Back/TopBar: back() -> [Topic Selection]
  - Dashboard: goDashboard() -> [Dashboard]

Quiz start & in-progress
- [Quiz Start] --load questions-->
  - GET /level/{id}
  - Initialize attempt object (attemptId in local state)
  - navigate -> [Quiz In-Progress]

- [Quiz In-Progress]
  - Actions:
    - answerQuestion(qId, answer)
      - Save local answers; if immediate feedback mode, show feedback
    - submitQuiz()
      - Validate answers; compute score
      - POST /attempts {levelId, answers, score}
  - Edge:
    - Attempt can be saved as draft (pause) -> localStorage
    - Navigation away prompts confirmation dialog
  - On submit:
    - if score >= 70%:
      - mark level completed (server saves best_score/complete=true)
      - unlock next level
      - show result -> [Quiz Result (pass)]
    - else:
      - save score (attempt)
      - show result -> [Quiz Result (fail)]

Quiz Result
- [Quiz Result]
  - Show summary, reward message, best score, buttons:
    - Retry -> [Quiz Start] (reinitialize attempt)
    - Next Level (if unlocked) -> [Quiz Start] with next level
    - Back to Levels -> [Level Selection]
    - Dashboard -> [Dashboard]

Dashboard
- [Dashboard]
  - Display aggregated user progress, badges, recent attempts
  - Actions:
    - Resume last attempt -> either [Quiz In-Progress] or [Level Selection]
    - View topic details -> [Topic Selection]
    - Switch age group -> [Welcome / Age Selection]

Persistence & Edge Cases
- Guests: use localStorage for progress; option to claim progress on registration.
- Offline: allow read-only browsing of previously cached levels; attempts queued and synced when online.
- Admin changes (e.g., delete topic): client invalidates caches and shows message.

State machine summary (compact)
- Welcome -> TopicSelection -> LevelSelection -> QuizInProgress -> QuizResult -> (LevelSelection | NextLevel)
- Dashboard can be reached from any main screen
- Back navigation always available and preserves in-progress attempt state (with confirmation on leave)

End of flowchart.