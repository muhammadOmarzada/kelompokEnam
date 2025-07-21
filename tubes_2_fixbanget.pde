import ddf.minim.*;
// ========================================================================
// GAMBAR (PImage) & ASET
// ========================================================================
PImage santriImg, santriKebingunganImg, santriTercerahkanImg, sunanImg, sunanTunjukImg, pemancing1Img, pemancing2Img;
PImage santriJalan1Img, santriJalan2Img, santriJalan3Img;
PImage sunanJalan1Img, sunanJalan2Img, sunanJalan3Img;

// ========================================================================
// VARIABEL SUARA
// ========================================================================
//--- AUDIO --- 2. Deklarasi variabel untuk library dan file suara
Minim minim;
AudioPlayer musikLatar;
AudioSample sfxScene1, sfxScene2, sfxScene3, sfxScene4, sfxScene5, sfxScene6, sfxScene7;

// ========================================================================
// VARIABEL UTAMA & STATUS
// ========================================================================
int currentScene;

// Posisi Karakter
float santriX, santriY;
float sunanX, sunanY;
float pemancing1X, pemancing1Y;
float pemancing2X, pemancing2Y;

// Status Aksi Karakter
boolean santriWalking;
boolean sunanWalking;

// ========================================================================
// VARIABEL ANIMASI
// ========================================================================
// Lingkungan
float cloudOffset = 0;
float riverFlowOffset = 0;
float windOffset = 0;
final float windStrength = 0.5;
final float windSpeed = 0.02;

// Sprite
float walkAnimationTimer = 0;
int walkSpriteIndex = 0;
final float walkAnimationSpeed = 0.08;
int walkDirection = 1;

float sunanWalkTimer = 0;
int sunanWalkIndex = 0;
final float sunanWalkSpeed = 0.08;
int sunanWalkDirection = 1;


// ========================================================================
// SISTEM DIALOG & TRANSISI (TYPEWRITER)
// ========================================================================
TypewriterData currentTypewriter;
float sceneTransitionTimer = 0.0;
// *** PERUBAHAN KUNCI: Variabel ini tidak lagi final (konstan) ***
float delayBetweenScenes;

// ========================================================================
// FUNGSI SETUP()
// ========================================================================
void setup() {
  size(800, 600);
  frameRate(60);

  // Load semua gambar
  try {
    santriImg = loadImage("santri.png");
    santriKebingunganImg = loadImage("santri_kebingungan.png");
    santriTercerahkanImg = loadImage("santri_tercerahkan.png");
    sunanImg = loadImage("sunan.png");
    sunanTunjukImg = loadImage("sunan_tunjuk.png");
    pemancing1Img = loadImage("pemancing1.png");
    pemancing2Img = loadImage("pemancing2.png");
    santriJalan1Img = loadImage("santri_jalan1.png");
    santriJalan2Img = loadImage("santri_jalan2.png");
    santriJalan3Img = loadImage("santri_jalan3.png");
    sunanJalan1Img = loadImage("sunan_jalan1.png");
    sunanJalan2Img = loadImage("sunan_jalan2.png");
    sunanJalan3Img = loadImage("sunan_jalan3.png");
  } catch (Exception e) {
    println("Gagal memuat gambar! Pastikan semua file .png ada di folder data.");
    e.printStackTrace();
    exit();
  }
  
  // Posisi awal pemancing
  pemancing1X = 150; 
  pemancing1Y = 450;
  pemancing2X = 600; 
  pemancing2Y = 450;
  
  // Load semua audio
  minim = new Minim(this);
  
  try {
    musikLatar = minim.loadFile("river-ambience.mp3"); 
    sfxScene1 = minim.loadSample("case 1.wav");
    sfxScene2 = minim.loadSample("case 2.wav");
    sfxScene3 = minim.loadSample("case 3.wav");
    sfxScene4 = minim.loadSample("case 4.wav");
    sfxScene5 = minim.loadSample("case 5.wav");
    sfxScene6 = minim.loadSample("case 6.wav");
    sfxScene7 = minim.loadSample("hikmah.wav");
    
    musikLatar.loop(); // Mainkan musik latar secara berulang
    
    musikLatar.setGain(-20.0f); 
  } catch (Exception e) {
    println("Gagal memuat file suara! Pastikan file audio ada di folder data dan nama file sudah benar.");
    e.printStackTrace();
  }

  // Memulai cerita dari scene pertama
  initializeScene(1);
}

// ========================================================================
// FUNGSI DRAW() - Loop utama program
// ========================================================================
void draw() {
  drawBackground();
  updateAnimations();
  drawPemancing();
  drawSantri();
  drawSunan();
  updateTypewriter();
  drawDialog();
  handleSceneTransition();

  // *** PERUBAHAN KUNCI: Timer untuk adegan penutup ***
  if (currentScene == 7) {
    sceneTransitionTimer += 1.0 / frameRate;
    if (sceneTransitionTimer >= delayBetweenScenes) {
      musikLatar.pause(); // Hentikan musik saat cerita selesai
      fill(0, 0, 0, 150);
      rect(0, height/2 - 30, width, 60);
      fill(255, 215, 0);
      textSize(24);
      textAlign(CENTER, CENTER);
      text("~ AKHIR CERITA ~", width/2, height/2);
      noLoop(); 
    }
  }
}

// ========================================================================
// MANAJEMEN SCENE & STATE
// ========================================================================
void initializeScene(int sceneNumber) {
  currentScene = sceneNumber;
  
  // Reset timer transisi
  sceneTransitionTimer = 0;

  // Reset dan siapkan data typewriter untuk scene ini
  currentTypewriter = new TypewriterData();
  currentTypewriter.displayedText = "";
  currentTypewriter.charIndex = 0;
  currentTypewriter.timer = 0;
  currentTypewriter.isFinished = false;

  // *** PERUBAHAN KUNCI: Durasi setiap adegan diatur di sini ***
  // Total durasi = (15+15) + (10+10) + (15+20) + (10+10) + (20+25) + (20+25) + 55 = 255 detik (sedikit lebih)
  // Mari kita targetkan 210 detik.
  // Scene 1: 25s | Scene 2: 15s | Scene 3: 30s | Scene 4: 15s | Scene 5: 35s | Scene 6: 35s | Scene 7: 55s = 210s
  switch (sceneNumber) {
    case 1:
      if(sfxScene1 != null) sfxScene1.trigger();
      currentTypewriter.fullText = "Di sebuah desa yang damai, seorang santri muda kembali dari perjalanan menuntut ilmu.|Dengan dada membusung, ia merasa bangga atas ilmunya.|Di ujung sungai, Sunan Bonang sedang melihat ke arah sungai.";
      currentTypewriter.speed = 0.1;
      delayBetweenScenes = 12.0; 
      santriX = -100;
      sunanX = 500; 
      sunanY = 385;
      santriY = sunanY; 
      santriWalking = true;
      sunanWalking = false;
      break;
    case 2:
      if(sfxScene2 != null) sfxScene2.trigger();
      currentTypewriter.fullText = "\"Aku sudah belajar banyak ilmu agama... Mereka ini (para pemancing) pasti tidak tahu apa-apa.\"";
      currentTypewriter.speed = 0.15;
      delayBetweenScenes = 8.0;
      break;
    case 3:
      if(sfxScene3 != null) sfxScene3.trigger();
      currentTypewriter.fullText = "\"Wahai anak muda… Bisakah kau jelaskan, apakah yang disebut ilmu sejati?\"";
      currentTypewriter.speed = 0.15;
      delayBetweenScenes = 20.0;
      sunanWalking = true;
      break;
    case 4:
      if(sfxScene4 != null) sfxScene4.trigger();
      currentTypewriter.fullText = "\"Ilmu sejati… eh… tentu yang paling tinggi dan banyak!\"";
      currentTypewriter.speed = 0.2;
      delayBetweenScenes = 8.0;
      break;
    case 5:
      if(sfxScene5 != null) sfxScene5.trigger();
      currentTypewriter.fullText = "\"Lihatlah air ini... ilmu sejati adalah yang terus mengalir memberi manfaat,|bukan ditampung untuk menyombongkan diri.\"";
      currentTypewriter.speed = 0.15;
      delayBetweenScenes = 20.0;
      break;
    case 6:
      if(sfxScene6 != null) sfxScene6.trigger();
      currentTypewriter.fullText = "\"Aku paham sekarang… Ilmu bukan untuk dibanggakan, tapi untuk diamalkan demi kebaikan bersama.\"";
      currentTypewriter.speed = 0.15;
      delayBetweenScenes = 20.0;
      break;
    case 7:
      if(sfxScene7 != null) sfxScene7.trigger();
      currentTypewriter.fullText = "";
      currentTypewriter.isFinished = true;
      delayBetweenScenes = 55.0; 
      break;
  }
}

void handleSceneTransition() {
  if (currentTypewriter.isFinished && currentScene < 7) {
    sceneTransitionTimer += 1.0 / frameRate;

    if (sceneTransitionTimer >= delayBetweenScenes) {
      initializeScene(currentScene + 1);
    }
  }
}

// ========================================================================
// FUNGSI UPDATE & DRAW KARAKTER
// ========================================================================
void updateAnimations() {
  // Animasi lingkungan (selalu berjalan)
  cloudOffset += 0.2;
  riverFlowOffset += 1.5;
  windOffset += windSpeed;

  // Animasi karakter spesifik per scene
  switch (currentScene) {
    case 1:
      if (santriWalking && santriX < sunanX - 150) {
        santriX += 1.2; // Kecepatan santri
        santriY = sunanY + sin(frameCount * 0.2) * 2; // Efek membusung
        walkAnimationTimer += walkAnimationSpeed;
        if (walkAnimationTimer >= 1.0) {
          walkSpriteIndex += walkDirection;
          if (walkSpriteIndex >= 2) {
            walkSpriteIndex = 2;
            walkDirection = -1;
          } else if (walkSpriteIndex <= 0) {
            walkSpriteIndex = 0;
            walkDirection = 1;
          }
          walkAnimationTimer = 0;
        }
      } else {
        santriWalking = false;
        santriY = sunanY; // Posisi stabil
      }
      break;
    case 3:
      if (sunanWalking && sunanX > santriX + 80) {
        sunanX -= 0.8; // Kecepatan sunan
        sunanY = 385 + sin(frameCount * 0.25) * 1.5; // Efek berjalan
        santriY = sunanY; // Pastikan santri tetap sejajar
        sunanWalkTimer += sunanWalkSpeed;
        if (sunanWalkTimer >= 1.0) {
          sunanWalkIndex += sunanWalkDirection;
          if (sunanWalkIndex >= 2) {
            sunanWalkIndex = 2;
            sunanWalkDirection = -1;
          } else if (sunanWalkIndex <= 0) {
            sunanWalkIndex = 0;
            sunanWalkDirection = 1;
          }
          sunanWalkTimer = 0;
        }
      } else {
        sunanWalking = false;
        sunanY = 385; // Posisi stabil
        santriY = sunanY;
      }
      break;
  }
}

void drawPemancing() {
  // Gambar Pemancing dengan efek bouncing
  pushMatrix();
  translate(pemancing1X + sin(frameCount * 0.1) * 1.5, pemancing1Y + sin(frameCount * 0.15) * 3);
  image(pemancing1Img, 0, 0);
  popMatrix();
  
  pushMatrix();
  translate(pemancing2X + sin(frameCount * 0.08 + PI/2) * 2, pemancing2Y + sin(frameCount * 0.12 + PI/3) * 3.5);
  image(pemancing2Img, 0, 0);
  popMatrix();
}

void drawSantri() {
  // Gambar Santri (gambar berubah sesuai scene)
  PImage santriSprite = santriImg; // Gambar default
  float santriScale = 0.5;
  float santriOffsetX = 0, santriOffsetY = 0;

  if (santriWalking) {
    if (walkSpriteIndex == 0) santriSprite = santriJalan1Img;
    else if (walkSpriteIndex == 1) santriSprite = santriJalan2Img;
    else santriSprite = santriJalan3Img;
  } else if (currentScene == 4 || currentScene == 5) {
    santriSprite = santriKebingunganImg;
    santriScale = 0.65;
    santriOffsetX = -10; 
    santriOffsetY = -15;
  } else if (currentScene >= 6) {
    santriSprite = santriTercerahkanImg;
    santriScale = 0.65;
    santriOffsetX = -5; 
    santriOffsetY = -15;
  }
  
  pushMatrix();
  translate(santriX + santriOffsetX, santriY + santriOffsetY);
  scale(santriScale);
  image(santriSprite, 0, 0);
  popMatrix();
}

void drawSunan() {
  // Gambar Sunan (gambar berubah sesuai scene)
  PImage sunanSprite = sunanImg;
  float sunanScale = 0.6;
  float sunanOffsetY = 0;
  
  if (sunanWalking) {
    if (sunanWalkIndex == 0) sunanSprite = sunanJalan1Img;
    else if (sunanWalkIndex == 1) sunanSprite = sunanJalan2Img;
    else sunanSprite = sunanJalan3Img;
  } else if (currentScene == 5) {
    sunanSprite = sunanTunjukImg;
    sunanScale = 0.65;
    sunanOffsetY = -9;
  }

  pushMatrix();
  translate(sunanX, sunanY + sunanOffsetY);
  scale(sunanScale);
  image(sunanSprite, 0, 0);
  popMatrix();
}

// ========================================================================
// FUNGSI SISTEM DIALOG
// ========================================================================
void updateTypewriter() {
  if (!currentTypewriter.isFinished) {
    currentTypewriter.timer += currentTypewriter.speed;
    if (currentTypewriter.timer >= 1.0) {
      if (currentTypewriter.charIndex < currentTypewriter.fullText.length()) {
        char nextChar = currentTypewriter.fullText.charAt(currentTypewriter.charIndex);
        currentTypewriter.displayedText += (nextChar == '|') ? "\n" : nextChar;
        currentTypewriter.charIndex++;
      } else {
        currentTypewriter.isFinished = true;
      }
      currentTypewriter.timer = 0;
    }
  }
}

void drawDialog() {
  if (currentScene == 7) {
    drawClosingNarration();
    return;
  }
  if (currentTypewriter.fullText.isEmpty()) return;

  // Background box
  fill(0, 0, 0, 160);
  rect(10, 10, 780, 110);
  
  String speaker = "";
  String description = "";
  color speakerColor = color(255);
  
  switch(currentScene) {
    case 1: 
      speaker = "Narator:"; 
      break;
    case 2: 
      speaker = "Santri (dalam hati):"; 
      speakerColor = color(255, 255, 0); 
      description = "(Memandang pemancing dengan sombong)"; 
      break;
    case 3: 
      speaker = "Sunan Bonang:"; 
      speakerColor = color(0, 255, 0); 
      description = "(Berjalan mendekat dengan tenang)"; 
      break;
    case 4: 
      speaker = "Santri:"; 
      speakerColor = color(255, 255, 0); 
      description = "(Menjawab dengan ragu-ragu)"; 
      break;
    case 5: 
      speaker = "Sunan Bonang:"; 
      speakerColor = color(0, 255, 0); 
      description = "(Menunjuk ke arah sungai)"; 
      break;
    case 6: 
      speaker = "Santri:"; 
      speakerColor = color(255, 255, 0); 
      description = "(Wajahnya tampak tercerahkan)"; 
      break;
  }

  drawDialogBox(speaker, currentTypewriter.displayedText, description, speakerColor);
}

void drawDialogBox(String speaker, String dialog, String description, color c) {
  textAlign(LEFT, TOP);
  // Speaker
  fill(c);
  textSize(18);
  text(speaker, 25, 25);
  // Dialog
  fill(255);
  textSize(16);
  text(dialog, 25, 55);
  // Deskripsi (jika ada)
  if (!description.isEmpty()) {
    fill(200);
    textSize(14);
    text(description, 25, 95);
  }
  // Cursor
  if (!currentTypewriter.isFinished && frameCount % 40 < 20) {
    String[] lines = dialog.split("\n");
    float cursorX = 25 + textWidth(lines[lines.length - 1]);
    float cursorY = 55 + (lines.length - 1) * 20;
    fill(255, 255, 0);
    text("_", cursorX, cursorY);
  }
}

void drawClosingNarration() {
  fill(0, 0, 0, 200);
  rect(100, 200, 600, 200);
  fill(255, 215, 0);
  textAlign(CENTER, CENTER);
  textSize(24);
  text("HIKMAH SUNAN BONANG", 400, 250);
  fill(255);
  textSize(16);
  text("Ilmu sejati bukanlah tentang seberapa banyak yang kau miliki,\ntapi seberapa besar manfaatnya bagi sesama.", 400, 310);
}

// ========================================================================
// FUNGSI INPUT
// ========================================================================
void keyPressed() {
  if (key == ' ') {
    if (!currentTypewriter.isFinished) {
      // Langsung selesaikan typewriter
      currentTypewriter.displayedText = currentTypewriter.fullText.replace("|", "\n");
      currentTypewriter.isFinished = true;
    } else if (currentScene < 7) {
      // Langsung skip ke scene berikutnya
      initializeScene(currentScene + 1);
    }
  }
  // Tombol Reset
  if (key == 'r' || key == 'R') {
    // Mulai ulang dari awal dan aktifkan kembali loop
    loop(); 
    initializeScene(1);
  }
}

// ========================================================================
// FUNGSI GAMBAR LATAR BELAKANG & LINGKUNGAN (SESUAI PERMINTAAN)
// ========================================================================
void drawBackground() {
  // Langit biru
  fill(0, 191, 255);
  noStroke();
  rect(0, 0, 800, 420);
  
  // Tanah hijau
  fill(76, 175, 80);
  rect(0, 420, 800, 180);
  
  // Sungai
  fill(0, 119, 255);
  rect(0, 500, 800, 100);
  
  // Gambar efek arus sungai
  drawRiverFlow();
  
  // Gambar matahari
  drawSun();
  
  // Gambar awan
  drawClouds();
  
  // Gambar gunung-gunung
  drawMountains();
  
  // Gambar pepohonan dengan efek angin
  drawTrees();
  
  stroke(0); // Kembalikan stroke ke default
}

void drawMountains() {
  stroke(0);
  // Gunung besar di tengah
  fill(47, 79, 79);
  beginShape();
  vertex(250, 420);
  vertex(400, 150);
  vertex(550, 420);
  endShape(CLOSE);
  
  // Gunung kiri
  fill(60, 90, 90);  
  beginShape();
  vertex(50, 420);
  vertex(150, 200);
  vertex(280, 420);
  endShape(CLOSE);
  
  // Gunung kanan
  fill(60, 90, 90);
  beginShape();
  vertex(520, 420);
  vertex(650, 220);
  vertex(750, 420);
  endShape(CLOSE);
  
  // Gunung jauh di belakang (kiri)
  fill(70, 100, 100);
  beginShape();
  vertex(0, 420);
  vertex(80, 280);
  vertex(180, 420);
  endShape(CLOSE);
  
  // Gunung jauh di belakang (kanan)
  fill(70, 100, 100);
  beginShape();
  vertex(680, 420);
  vertex(750, 250);
  vertex(800, 420);
  endShape(CLOSE);
}

void drawRiverFlow() {
  // Efek arus sungai dengan garis-garis gelombang
  stroke(0, 150, 255); // Warna biru lebih terang
  strokeWeight(2);
  
  // Garis arus utama
  for (int i = 0; i < 5; i++) {
    float y = 520 + i * 15;
    float waveHeight = 3 + i * 0.5;
    beginShape();
    noFill();
    for (int x = -50; x <= 850; x += 10) {
      float wave = sin((x + riverFlowOffset + i * 50) * 0.02) * waveHeight;
      vertex(x, y + wave);
    }
    endShape();
  }
  
  // Garis arus kedua
  stroke(0, 100, 220);
  strokeWeight(1.5);
  for (int i = 0; i < 3; i++) {
    float y = 530 + i * 20;
    float waveHeight = 2 + i * 0.3;
    beginShape();
    noFill();
    for (int x = -50; x <= 850; x += 15) {
      float wave = sin((x + riverFlowOffset * 0.7 + i * 80) * 0.015) * waveHeight;
      vertex(x, y + wave);
    }
    endShape();
  }
  
  // Efek riak-riak kecil
  stroke(255, 255, 255, 100);
  strokeWeight(1);
  for (int i = 0; i < 4; i++) {
    float y = 510 + i * 18;
    float waveHeight = 1.5;
    beginShape();
    noFill();
    for (int x = -30; x <= 830; x += 20) {
      float wave = sin((x + riverFlowOffset * 1.2 + i * 60) * 0.025) * waveHeight;
      vertex(x, y + wave);
    }
    endShape();
  }
  
  // Reset stroke
  strokeWeight(1);
  stroke(0);
}

void drawTrees() {
  stroke(0);
  // Pohon cemara di tengah
  float windSway1 = sin(windOffset + 0) * windStrength * 3;
  drawPineTree(400 + windSway1, 420, 60, 120, windSway1);
  
  // Pohon bulat kiri
  float windSway2 = sin(windOffset + 1.5) * windStrength * 2.5;
  drawRoundTree(120 + windSway2, 420, 50, 80, windSway2);
  
  // Pohon bulat kanan
  float windSway3 = sin(windOffset + 3) * windStrength * 2.8;
  drawRoundTree(680 + windSway3, 420, 45, 75, windSway3);
  
  // Pohon cemara kecil
  float windSway4 = sin(windOffset + 2) * windStrength * 2;
  drawPineTree(200 + windSway4, 420, 40, 80, windSway4);
  
  float windSway5 = sin(windOffset + 4.5) * windStrength * 2.2;
  drawPineTree(600 + windSway5, 420, 35, 70, windSway5);
  
  // Pohon bulat kecil
  float windSway6 = sin(windOffset + 1) * windStrength * 1.8;
  drawRoundTree(300 + windSway6, 420, 35, 60, windSway6);
  
  float windSway7 = sin(windOffset + 3.5) * windStrength * 2.1;
  drawRoundTree(500 + windSway7, 420, 40, 65, windSway7);
}

void drawPineTree(float x, float y, float treeWidth, float treeHeight, float windSway) {
  stroke(0);
  // Batang
  fill(101, 67, 33);
  beginShape();
  vertex(x - windSway - 8, y);
  vertex(x - windSway + 8, y);
  vertex(x - windSway + 8, y - treeHeight * 0.2);
  vertex(x - windSway - 8, y - treeHeight * 0.2);
  endShape(CLOSE);
  
  // Daun
  fill(34, 139, 34);
  float windEffect1 = windSway * 0.3;
  beginShape();
  vertex(x - treeWidth * 0.5 + windEffect1, y - treeHeight * 0.1);
  vertex(x + windSway * 0.5, y - treeHeight * 0.4);
  vertex(x + treeWidth * 0.5 + windEffect1, y - treeHeight * 0.1);
  endShape(CLOSE);
  
  float windEffect2 = windSway * 0.6;
  beginShape();
  vertex(x - treeWidth * 0.4 + windEffect2, y - treeHeight * 0.3);
  vertex(x + windSway * 0.7, y - treeHeight * 0.7);
  vertex(x + treeWidth * 0.4 + windEffect2, y - treeHeight * 0.3);
  endShape(CLOSE);
  
  float windEffect3 = windSway * 0.9;
  beginShape();
  vertex(x - treeWidth * 0.3 + windEffect3, y - treeHeight * 0.6);
  vertex(x + windSway, y - treeHeight);
  vertex(x + treeWidth * 0.3 + windEffect3, y - treeHeight * 0.6);
  endShape(CLOSE);
}

void drawRoundTree(float x, float y, float trunkWidth, float treeHeight, float windSway) {
  stroke(0);
  // Batang
  fill(101, 67, 33);
  beginShape();
  vertex(x - windSway - trunkWidth * 0.15, y);
  vertex(x - windSway + trunkWidth * 0.15, y);
  vertex(x - windSway + trunkWidth * 0.15, y - treeHeight * 0.4);
  vertex(x - windSway - trunkWidth * 0.15, y - treeHeight * 0.4);
  endShape(CLOSE);
  
  // Mahkota pohon
  fill(76, 175, 80);
  drawCircleWithVertex(x + windSway * 0.7, y - treeHeight * 0.7, trunkWidth * 1.8);
}

void drawClouds() {
  noStroke();
  fill(255);
  // Awan besar
  drawCloud((600 + cloudOffset) % 900 - 100, 80, 80);
  // Awan sedang
  drawCloud((100 + cloudOffset * 0.7) % 900 - 100, 60, 60);
  // Awan kecil
  drawCloud((400 + cloudOffset * 0.5) % 900 - 100, 40, 45);
  drawCloud((720 + cloudOffset * 1.3) % 900 - 100, 120, 40);
  drawCloud((50 + cloudOffset * 0.3) % 900 - 100, 150, 35);
}

void drawCloud(float x, float y, float size) {
  drawCircleWithVertex(x, y, size);
  drawCircleWithVertex(x - size * 0.4, y + size * 0.1, size * 0.8);
  drawCircleWithVertex(x + size * 0.4, y + size * 0.1, size * 0.8);
  drawCircleWithVertex(x - size * 0.2, y - size * 0.3, size * 0.6);
  drawCircleWithVertex(x + size * 0.2, y - size * 0.3, size * 0.6);
  drawCircleWithVertex(x, y + size * 0.3, size * 0.7);
}

void drawSun() {
  fill(255, 255, 0);
  stroke(255, 200, 0);
  strokeWeight(2);
  drawCircleWithVertex(150, 120, 100);
  strokeWeight(1);
}

void drawCircleWithVertex(float centerX, float centerY, float diameter) {
  beginShape();
  for (int i = 0; i < 16; i++) {
    float angle = map(i, 0, 16, 0, TWO_PI);
    float x = centerX + cos(angle) * diameter / 2;
    float y = centerY + sin(angle) * diameter / 2;
    vertex(x, y);
  }
  endShape(CLOSE);
}

void stop() {
  if (musikLatar != null) {
    musikLatar.close();
  }
  minim.stop();
  super.stop();
}

class TypewriterData {
  String fullText;
  String displayedText;
  int charIndex;
  float timer;
  boolean isFinished;
  float speed;
}
