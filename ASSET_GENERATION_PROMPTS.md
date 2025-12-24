# MG-0009 Snake Game - AI 에셋 생성 프롬프트

이 문서는 MG-0009 Snake Game에 필요한 그래픽/사운드 에셋을 AI 도구로 생성할 때 사용할 프롬프트 모음입니다.

---

## 🎨 그래픽 에셋

### 1. 뱀 (Snake) 스프라이트

**현재 구현**: 녹색 사각형 (머리: 진한 녹색, 몸통: 연한 녹색) + 눈

**AI 이미지 생성 프롬프트**:
```
Pixel art snake sprites for classic Snake game,
grid-based design, green color scheme,
separate sprites for: head, body segments, tail,
simple retro style, transparent background, PNG format

Components needed:
1. Snake head (4 directions: up, down, left, right)
   - Size: 32x32 pixels per direction
   - Dark green (#228B22) with white eyes
   - Eyes position changes based on direction

2. Snake body segment
   - Size: 32x32 pixels
   - Light green (#90EE90)
   - Simple rectangular or slightly rounded

3. Snake tail (4 directions)
   - Size: 32x32 pixels
   - Tapered end, light green
   - Matches body color

Style: pixel art, retro, simple geometric
Colors: dark green (#228B22), light green (#90EE90), white (#FFFFFF), black (#000000)
```

**Midjourney/DALL-E 스타일**:
```
pixel art snake game character sprite sheet,
green snake head with eyes facing 4 directions,
body segments and tail pieces, retro game style,
simple geometric design, transparent background --ar 4:1 --v 5
```

---

### 2. 먹이 (Food) 스프라이트

**현재 구현**: 빨간색 타원형

**AI 이미지 생성 프롬프트**:
```
Pixel art food/apple sprite for Snake game,
32x32 pixels, bright red color (#FF0000),
simple round shape (apple or berry),
retro 8-bit style, transparent background, PNG format

Design options:
- Classic red apple with small leaf
- Red berry/fruit
- Glowing red orb
- Simple red circle with highlight

Style: pixel art, retro, appetizing
Colors: red (#FF0000), dark red (#8B0000), green leaf (optional)
```

**특수 먹이 변형**:
```
Create 3 food variants for power-ups:
1. Golden apple (2x score, yellow/gold)
2. Blue berry (slow down snake, blue)
3. Rainbow fruit (bonus points, multi-color)

Each: 32x32 pixels, pixel art style, distinct colors
```

---

### 3. 배경 (Background)

**현재 구현**: 어두운 단색 (#1a1a1a) + 그리드 선

**AI 이미지 생성 프롬프트**:
```
Snake game background, pixel art retro style,
dark theme (#1a1a1a to #2a2a2a gradient),
subtle grid pattern overlay, minimalist design,
1920x1080 resolution, suitable for tiled/seamless pattern

Elements:
- Base: dark gray gradient (#1a1a1a)
- Grid: very subtle white lines (10% opacity)
- Optional: faint retro circuit/tech pattern in background
- Clean and not distracting

Style: pixel art, dark, minimalist, retro
```

**배경 테마 변형**:
```
Create 3 background themes:
1. Classic Dark: dark gray with grid (current)
2. Neon: dark blue/purple with glowing grid lines
3. Retro Green: CRT monitor green tint (#003300)
4. Nature: grass texture pattern (green theme)

All: subtle, non-distracting, maintains grid visibility
```

---

### 4. 그리드/보드 요소

**벽/경계 스프라이트**:
```
Pixel art wall/border sprites for Snake game,
32x32 pixels per tile, brick or stone texture,
dark gray (#404040) to match game aesthetic,
tileable horizontally and vertically, pixel art style,
PNG format with transparency

Tiles needed:
- Straight wall (horizontal and vertical)
- Corner pieces (4 corners)
- Optional: decorative border variations

Style: pixel art, dark, solid
Colors: dark gray (#404040), black outline
```

---

### 5. UI 요소

**점수 패널**:
```
Pixel art UI panel for score display,
200x60 pixels, semi-transparent dark background,
retro game HUD style, suitable for top-left corner,
border with slight glow effect, PNG with alpha

Style: pixel art, retro HUD, minimalist
Colors: dark gray background, white/green text compatible
```

**게임 오버 배너**:
```
Pixel art "GAME OVER" banner/panel,
400x200 pixels, red accent color (#FF0000),
dark semi-transparent background for contrast,
retro game over screen aesthetic, PNG format

Elements:
- "GAME OVER" text area (centered)
- Score display area
- "Press SPACE to restart" instruction area
- Optional: small snake skull icon

Style: pixel art, dramatic but not too aggressive
Colors: red (#FF0000), dark gray background, white text
```

**시작 화면 로고**:
```
Pixel art "SNAKE" game logo/title,
500x150 pixels, retro 8-bit style font,
green color theme matching snake, bold and readable,
optional small snake graphic incorporated into letters,
PNG with transparency

Style: pixel art, bold, retro game title
Colors: green (#228B22), dark outline, white highlights
```

---

## 🔊 사운드 에셋

### 1. 뱀 이동 사운드

**먹이 섭취 사운드**:
```
Audio prompt for AI sound generation:

"8-bit retro eating/chomp sound effect for Snake game,
short 0.2 second duration, satisfying crunch/bite sound,
mid-pitched, cheerful tone, chiptune synthesizer style,
classic arcade game aesthetic, WAV format"

Parameters:
- Duration: 0.2s
- Pitch: mid (C4-E4)
- Style: chiptune, bite/crunch
- Tone: satisfying, cheerful
```

**뱀 이동 사운드** (선택적):
```
"Very subtle 8-bit slither/slide sound effect,
extremely short 0.05 second, soft tick/click,
high-pitched, minimalist, can loop frequently,
background ambient sound for snake movement, WAV format"

Parameters:
- Duration: 0.05s
- Pitch: high (E5-G5)
- Style: chiptune, subtle tick
- Volume: very low (background)
- Loop: yes
```

---

### 2. 게임 이벤트 사운드

**충돌/게임 오버 사운드**:
```
"8-bit crash/death sound effect for Snake game,
0.5 second duration, descending pitch with impact,
dramatic but not harsh, classic game over tone,
chiptune synthesizer, WAV format"

Parameters:
- Duration: 0.5s
- Pitch: descending (E4 to C3)
- Style: chiptune, crash + descend
- Tone: game over, slightly dramatic
```

**벽 충돌 사운드**:
```
"8-bit wall bump/hit sound effect,
very short 0.15 second, sharp impact sound,
Snake game collision tone, chiptune style,
crisp and clear, WAV format"

Parameters:
- Duration: 0.15s
- Pitch: low-mid (C3-E3)
- Style: chiptune, sharp impact
```

---

### 3. UI 사운드

**방향 전환 사운드** (선택적):
```
"Very subtle 8-bit direction change beep,
extremely short 0.08 second, soft click/tick,
high-pitched, minimal, responsive feel,
chiptune style, WAV format"

Parameters:
- Duration: 0.08s
- Pitch: high (G4)
- Style: chiptune, soft beep
- Volume: subtle
```

**점수 카운트업 사운드**:
```
"8-bit point scored sound, 0.15 second,
ascending pitch ding, rewarding tone,
classic arcade score sound, chiptune style,
bright and satisfying, WAV format"

Parameters:
- Duration: 0.15s
- Pitch: ascending (C4 to E4)
- Style: chiptune, ding/bell
- Tone: rewarding
```

---

### 4. 배경 음악

**게임플레이 BGM**:
```
"Retro chiptune background music for Snake game,
simple repetitive melody, moderate tempo (110-130 BPM),
not distracting, hypnotic and steady rhythm,
60-90 second loopable track, 8-bit style, C minor key,
minimalist instrumentation (lead + bass + subtle percussion)"

Style: chiptune, 8-bit, hypnotic
Mood: focused, steady, not too energetic
Tempo: 110-130 BPM
Key: C minor (slightly mysterious)
Length: 60-90 seconds (seamless loop)
Instruments: square wave lead, triangle bass, noise hi-hat
Reference: classic arcade puzzle game music
```

**메뉴/시작 화면 음악** (선택):
```
"Calm chiptune menu music for Snake game,
slower tempo (80-100 BPM), welcoming and simple,
30-45 second loop, 8-bit style, C major key,
very minimalist melody, non-intrusive"

Style: chiptune, minimal, ambient
Mood: calm, welcoming
Tempo: 80-100 BPM
```

---

## 🎨 추가 에셋 (확장 기능용)

### 뱀 스킨 변형

**다양한 뱀 색상 테마**:
```
Pixel art snake sprite variations,
same size (32x32 per segment), different color schemes:

1. Classic Green (current)
2. Blue Snake - electric/neon theme (#0066FF, #66B3FF)
3. Red Snake - fire theme (#FF3300, #FF9966)
4. Purple Snake - royal theme (#9933FF, #CC99FF)
5. Rainbow Snake - each segment different color

Each with: head (4 directions), body, tail
Style: pixel art, consistent design
Format: sprite sheets or individual PNGs
```

---

### 파티클 효과

**먹이 섭취 파티클**:
```
Pixel art particle sprites for food eating effect,
small 8x8 to 12x12 pixel pieces, green/white sparkles,
4-6 individual particles for scatter animation,
simple pixel art style, PNG with transparency

Style: pixel art, sparkly
Colors: light green, white, yellow highlights
Usage: burst effect when snake eats food
Animation: 3-4 frames of expansion/fade
```

**충돌 파티클**:
```
Pixel art explosion/crash particles,
small debris pieces (8x8 pixels), green/gray colors,
6-8 particles for scatter effect on death,
simple pixel art, PNG format

Style: pixel art, impact debris
Colors: dark green, gray, white
Usage: scatter on wall/self collision
```

---

### 파워업 아이템 스프라이트

**속도 감소 아이템**:
```
Pixel art clock/hourglass power-up sprite,
32x32 pixels, blue color theme,
slows down snake movement temporarily,
pixel art retro style, PNG with transparency

Style: pixel art, clear icon
Colors: blue (#0066FF), white, light blue
```

**벽 통과 아이템**:
```
Pixel art ghost/portal power-up sprite,
32x32 pixels, purple/pink color theme,
allows snake to pass through walls temporarily,
pixel art style, PNG format

Style: pixel art, magical/ethereal
Colors: purple (#9933FF), pink (#FF66FF), white glow
```

---

## 🛠️ 에셋 생성 도구 추천

### 그래픽
- **Aseprite**: 픽셀 아트 전문 (유료) - Snake 스프라이트 제작에 최적
- **Piskel**: 무료 온라인 픽셀 아트 에디터
- **GraphicsGale**: 픽셀 아트 (무료)
- **Lospec**: 픽셀 아트 팔레트 라이브러리

### 사운드
- **BFXR**: 무료 8-bit 효과음 생성기
- **ChipTone**: 브라우저 기반 칩튠 효과음
- **Audacity**: 무료 오디오 편집
- **LMMS**: 칩튠 음악 제작

### 음악
- **BeepBox**: 무료 온라인 칩튠 작곡
- **FamiTracker**: NES 스타일 작곡
- **Bosca Ceoil**: 간단한 루프 음악

---

## 📋 에셋 체크리스트

### 필수 에셋 (현재 게임용)
- [ ] 뱀 머리 스프라이트 (4 방향)
- [ ] 뱀 몸통 스프라이트
- [ ] 뱀 꼬리 스프라이트 (4 방향)
- [ ] 먹이 스프라이트 (사과/베리)
- [ ] 배경 이미지/패턴
- [ ] 먹이 섭취 사운드
- [ ] 충돌 사운드
- [ ] 배경 음악 (BGM)

### 확장 에셋 (추가 기능용)
- [ ] 뱀 스킨 변형 (3-4종)
- [ ] 특수 먹이 스프라이트 (파워업)
- [ ] 벽/경계 타일
- [ ] UI 패널/배너
- [ ] 먹이 섭취 파티클
- [ ] 충돌 파티클
- [ ] 방향 전환 사운드
- [ ] 점수 획득 사운드

---

## 💡 에셋 최적화 팁

1. **그리드 정렬**: 모든 스프라이트는 32x32 픽셀 (그리드 셀 크기)
2. **색상 팔레트**: 제한된 색상 (8-16 colors) 사용
3. **파일 크기**: PNG 최적화 (TinyPNG)
4. **스프라이트 시트**: 방향별 스프라이트는 시트로 통합
5. **오디오 포맷**: WAV (개발), OGG (배포)
6. **애니메이션**: 뱀은 정적이므로 애니메이션 불필요 (간단함 유지)

---

## 🎨 Snake Game 스타일 가이드

### 색상 팔레트
```
Snake:
- Head: #228B22 (Forest Green)
- Body: #90EE90 (Light Green)
- Eyes: #FFFFFF (White), #000000 (Black pupil)

Food:
- Apple: #FF0000 (Red)
- Golden: #FFD700 (Gold)
- Special: #0066FF (Blue), #9933FF (Purple)

Background:
- Base: #1a1a1a (Very Dark Gray)
- Grid: #FFFFFF with 0.1 opacity (Subtle White)

UI:
- Text: #FFFFFF (White)
- Score: #00FF00 (Bright Green)
- Game Over: #FF0000 (Red)
```

### 디자인 원칙
- **단순함**: 명확한 기하학적 형태
- **고대비**: 뱀과 배경 명확히 구분
- **그리드 기반**: 모든 요소는 32x32 픽셀 그리드에 정렬
- **레트로**: 8-bit/16-bit 시대 Snake 게임 스타일 유지

---

## 🐍 클래식 Snake 참고 이미지

**Nokia Snake (1997) 스타일**:
- 단색 그래픽
- 사각형 세그먼트
- 최소한의 디테일
- 명확한 픽셀 경계

**현대적 리메이크 방향**:
- 그리드 기반 유지
- 미묘한 그라데이션 추가 가능
- 부드러운 애니메이션 (선택)
- 색상은 밝고 선명하게

---

**이 프롬프트들을 AI 에셋 생성 도구에 복사하여 사용하세요!**
