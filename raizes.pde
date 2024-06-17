import java.util.Collections;
import java.util.Map;
import java.util.concurrent.ConcurrentLinkedQueue;
import java.io.PrintWriter;
import java.io.File;

/*  */

ConcurrentLinkedQueue<PVector[]> queuedSegmentoPontos = new ConcurrentLinkedQueue<PVector[]>();
ConcurrentLinkedQueue<PVector[]> queuedEspinhoPontos = new ConcurrentLinkedQueue<PVector[]>();
boolean running = true;
int runningCounter = 0;
Thread saveThread;

/*  */

PImage galeriaImage;

/*  */
color dourado = color(193, 170, 47),
      backgroundColor = color(20, 20, 20);

String douradoStringHex = "#C1AA2F";

ArrayList<Linha> allLinhas = new ArrayList<Linha>();

float smoothness = 5;
int FRAME_RATE = int(smoothness * 60);

////////////////////////////
float noiseScale = random(0.01f, 0.001f);
float[] maxMin = {
  random(-150.0f, -30.0f),
  random(30.0f, 150.0f),
};

int pesoLinha = 3;

/*  */

////////////////////
////////////////////
////////////////////
//
// usingCaminhoVirtual: true ||| são gerados caminhos (para ser usado o rato para fazer o caminho da sala meter como false)
// showDebugCaminhoVirtual: true ||| mostra o caminho que está a ser desenhado
// saveGeneratedCaminho: true ||| salvar os frames do que está a ser gerado
//
////////////////////
////////////////////
////////////////////
CaminhoBezier caminhoVirtual;
boolean usingCaminhoVirtual = true;
boolean showDebugCaminhoVirtual = false;
boolean saveGeneratedCaminho = false;
int TEMPO = 30;
String folderPath = "";
int frameCounter = 0;

boolean drawing = true;

void settings(){
  if(!usingCaminhoVirtual) size(5 * 330, 1 * 330);
  else size(1920, 1080); /* size(1632, 918); */
}
////////////////////////////
void setup(){
  galeriaImage = loadImage("./galeria_ca_branco.png");
  background(backgroundColor);

  if(smoothness <= 0){
    println("smoothness must be greater than 0");
    exit();
  }
  frameRate(FRAME_RATE);

  if(usingCaminhoVirtual){
    caminhoVirtual = new CaminhoBezier(createNewCaminho());
    caminhoVirtual.debugBezier();
    allLinhas.add(new Linha(dourado, caminhoVirtual));

    if(saveGeneratedCaminho){
      folderPath = "saveFrames/" + System.currentTimeMillis() + "";
      File folder = new File(folderPath);
      if (!folder.exists()) {
        folder.mkdir();
      }
    }
  }
  else{
    allLinhas.add(new Linha(dourado));
    startSaveThread();
  }
}

////////////////////////////
void draw(){
  if(running){
    allLinhas.forEach(
      (linha) -> linha.desenhar()
    );

    if(!usingCaminhoVirtual) image(galeriaImage, 0, 0, width, height);
    else if(saveGeneratedCaminho){
      if(frameCounter == FRAME_RATE * TEMPO){
        println("============ FINALIZADO ============");
        exit();
      }
      else{
        println(frameCount / FRAME_RATE);
        saveFrame(folderPath + "/frame_" + nf(frameCounter, 7) + ".png");
        frameCounter++;
      }
    }
  }
  else if(runningCounter < 1){
    push();
      fill(backgroundColor, 220);
      rect(0, 0, width, height);
      fill(255);
      textSize(42);
      textAlign(CENTER);
      text("salbandu o éssebêagêa...", width * 0.5, height * 0.5);
      fill(dourado);
      textSize(24);
      text("\n\n(pode demorar uma beca oh chaval@)", width * 0.5, height * 0.5);
    pop();
    runningCounter++;
  }
  else callExit();
}

////////////////////////////
ArrayList<PVector> createNewCaminho(){
  ArrayList<PVector> vectorSet = new ArrayList<PVector>(){{
    PVector max = new PVector(
      int(random(2, 5)),
      int(random(2, 5))
    );
    PVector reducer = new PVector(
      height * random(0.03f, 0.07f),
      height * random(0.1f, 0.2f)
    );

    for(int ix = 0; ix <= max.x; ix += 1){
      for(int iy = 0; iy <= max.y; iy += 1){
        if((ix == 0) || (ix == max.x) || (iy == 0) || (iy == max.y)){
          PVector P = new PVector(
            constrain(map(ix, 0, max.x, reducer.x, width - reducer.x), reducer.x, width - reducer.x),
            constrain(map(iy, 0, max.y, reducer.y, height - reducer.y), reducer.y, height - reducer.y)
          );

          PVector directionMiddle = directionVector(P, new PVector(width * 0.5f, height * 0.5f));
          float maxMag = directionMiddle.mag();

          add(PVector.lerp(P, new PVector(width * 0.5f, height * 0.5f), random(0.1f, 0.7f)));
        }
      }
    }
  }};

  Collections.shuffle(vectorSet);

  return vectorSet;
}

////////////////////////////
void startSaveThread() {
  saveThread = new Thread(new Runnable() {
    public void run() {
      PrintWriter output = createWriter("points.svg");
      output.println("<?xml version=\"1.0\" standalone=\"no\"?>");
      output.println("<!DOCTYPE svg PUBLIC \"-//W3C//DTD SVG 1.1//EN\" \"http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd\">");
      output.println("<svg width=\"" + width + "\" height=\"" + height + "\" version=\"1.1\" xmlns=\"http://www.w3.org/2000/svg\">");
      /* output.print("<polyline points=\""); */
      
      while (running || !queuedSegmentoPontos.isEmpty() || !queuedEspinhoPontos.isEmpty()) {
        PVector[] pontosSegmento = queuedSegmentoPontos.poll();
        if (pontosSegmento != null) {
          PVector pontoA = pontosSegmento[0];
          PVector pontoB = pontosSegmento[1];
          output.print("<line ");
          output.print("x1=\"" + pontoA.x + "\" y1=\"" + pontoA.y + "\" x2=\"" + pontoB.x + "\" y2=\"" + pontoB.y + "\" ");
          output.println("style=\"stroke:" + douradoStringHex + ";stroke-width:" + pesoLinha + "\" />");
          /* output.print(pontoA.x + "," + pontoA.y + " "); */
        }

        PVector[] pontosEspinho = queuedEspinhoPontos.poll();
        if(pontosEspinho != null) {
          output.print("<polygon points=\"");
          output.print(pontosEspinho[0].x + "," + pontosEspinho[0].y + " ");
          output.print(pontosEspinho[1].x + "," + pontosEspinho[1].y + " ");
          output.print(pontosEspinho[2].x + "," + pontosEspinho[2].y + "\" ");
          output.println("fill=\"" + douradoStringHex + "\"/>");
        }
      }
      println("teste Finish");

      /* output.println("\" style=\"fill:none;stroke:black;stroke-width:1\" />"); */
      output.println("</svg>");
      output.flush();
      output.close();
    }
  });
  saveThread.start();
}

void keyPressed() {
  if(!usingCaminhoVirtual && (key == 'x' || key == 'X')) running = false;
  if(key == 'q' || key == 'Q') drawing = !drawing;
}

void callExit(){
  running = false;
  try {
    saveThread.join();
  } catch (InterruptedException e) {
    e.printStackTrace();
  }
  
  exit();
}