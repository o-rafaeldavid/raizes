class Linha{
  private boolean started = false;
  private float mult = 1;
  private float[] larguraBetween;

  private float largura, posAngle;
  private double tendencia;
  private color cor;
  
  private int iterationCount = 0;

  private PVector mainPoint, iterationPoint;

  // ESPINHO : https://prnt.sc/EIq9UC5_ORE2
  private boolean toGetPoint = false;
  private PVector firstForEspinho, nextForEspinho;
  private int lastEspinhoFrame = 0; //ultimo frame q se colocou um inicio ou o final de um espinho
  private String espinhoMode = "NOVOESPINHO"; // "NOVOESPINHO" (mais longo o intervalo) ou "STOPESPINHO" (intervalo mais curto)
  private float intervalNextEspinho = -1;
  private boolean choosedSide = false; // true: pontoA (segmento) | false: pontoB (segmento)
  private float[][] intervalBetweenEspinhoGen = {
    // intervalo entre a geração de novos espinhos      (random entre valor "min" e "max")
    {0.0f, 0.0f},
    // intervalo entre o inicio e o final de um espinho (random entre valor "min" e "max")
    {0.0f, 0.0f}
  };
  private float[] normalInterval = {0.0f, 0.0f};

  /////
  private CaminhoBezier caminhoVirtual;
  private float factorVirtual = 0.0f;
  private float dir = 1.0f;
  private float noiseScale = -1;
  private float[] noiseBetween = {0.005f, 0.0012f};
  private float multNoise = 1;
  private float[] minMaxCaminhoChange = {
    -70.0f,
    70.0f
  };

  //////////////////////////////////////////////////////
  /////
  Linha(color cor){
    this.posAngle = 0;
    this.cor = cor;
    this.genIntervalSpine(0);

    this.larguraBetween = new float[] {5, 4};
    this.largura = random(this.larguraBetween[1], this.larguraBetween[0]);

    intervalBetweenEspinhoGen = new float[][]{
      {2.1f, 3.2f},
      {1.0f, 1.5f}
    };

    normalInterval = new float[]{7, 17};
  }

  Linha(color cor, CaminhoBezier caminhoVirtual){
    this.posAngle = 0;
    this.cor = cor;
    this.genIntervalSpine(0);

    this.larguraBetween = new float[] {13, 4};
    this.largura = random(this.larguraBetween[0], this.larguraBetween[1]);
    
    this.caminhoVirtual = caminhoVirtual;
    this.noiseScale = random(noiseBetween[0], noiseBetween[1]);

    intervalBetweenEspinhoGen = new float[][]{
      {6.0f, 10.0f},
      {1.3f, 2.7f}
    };

    normalInterval = new float[]{15, 30};
  }
  /////
  /////
  
  void desenhar(){
    // verificação de caminho virtual
    if(caminhoVirtual == null) this.mainPoint = new PVector(mouseX, mouseY);
    else{
      PVector[] linha = this.caminhoVirtual.getPointsBetweenFactor(this.factorVirtual);
      float sizeLinha = directionVector(linha[0], linha[1]).mag();

      PVector fromCaminho = new PVector(
        this.caminhoVirtual.getPointBezier(constrain(this.factorVirtual, 0, 1)).x,
        this.caminhoVirtual.getPointBezier(constrain(this.factorVirtual, 0, 1)).y
      );
      float noiseVal = noise(fromCaminho.x * this.noiseScale, fromCaminho.y * this.noiseScale);

      this.mainPoint = new PVector(
        fromCaminho.x + map(noiseVal, 0, 1, minMaxCaminhoChange[0], minMaxCaminhoChange[1]),
        fromCaminho.y + map(noiseVal, 0, 1, minMaxCaminhoChange[0], minMaxCaminhoChange[1])
      );

      if(this.factorVirtual >= 1 /* || this.factorVirtual < 0 */){
        this.resetSpine();
        /* if(this.factorVirtual > 1) this.factorVirtual = 1;
        else this.factorVirtual = 0;
        
        this.dir = -1 * this.dir; */
        started = false;
        this.iterationPoint = null;
        
        this.factorVirtual = 0;

        ArrayList<PVector> oldPontos = this.caminhoVirtual.getAllPoints();
        ArrayList<PVector> newPontos = createNewCaminho();
        /* newPontos.set(0, oldPontos.get(0)); */
        this.caminhoVirtual = new CaminhoBezier(newPontos);

        background(backgroundColor);
        this.caminhoVirtual.debugBezier();

        fromCaminho = new PVector(
          this.caminhoVirtual.getPointBezier(constrain(this.factorVirtual, 0, 1)).x,
          this.caminhoVirtual.getPointBezier(constrain(this.factorVirtual, 0, 1)).y
        );
        noiseVal = noise(fromCaminho.x * this.noiseScale, fromCaminho.y * this.noiseScale);

        this.mainPoint = new PVector(
          fromCaminho.x + map(noiseVal, 0, 1, minMaxCaminhoChange[0], minMaxCaminhoChange[1]),
          fromCaminho.y + map(noiseVal, 0, 1, minMaxCaminhoChange[0], minMaxCaminhoChange[1])
        );
      }
      this.factorVirtual = constrain(this.factorVirtual + map(sizeLinha, 300, 900, 0.0018f, 0.0012f) * this.dir / smoothness, 0, 1);
    }

    /* println(this.factorVirtual); */
    
    PVector linhaDirection = (this.iterationPoint != null) ? directionVector(this.iterationPoint, this.mainPoint) : null;
    /* print("linhaDirection: ");
    println(linhaDirection);
    print("mainPoint: ");
    println(linhaDirection);
    print("started: ");
    println(started); */

    ////
    if(!started && this.iterationPoint == null && this.mainPoint.x != 0 && this.mainPoint.y != 0){
      started = true;
      this.iterationPoint = this.mainPoint;
      /* println("started to true ");
      println("iterationPoint to main"); */
    } ////
    else if(started && !(linhaDirection.x == 0 && linhaDirection.y == 0)){
      /* println("inside it"); */
      /*  */
      if(this.largura > this.larguraBetween[0] || this.largura < this.larguraBetween[1]) this.mult *= -1;
      this.largura += this.mult * 0.5f / smoothness;
      if(this.multNoise > this.noiseBetween[0]  || this.multNoise < this.noiseBetween[1] ) this.multNoise *= -1;
      this.noiseScale += this.multNoise * random(0.00007f, 0.0002f) / smoothness;
      /*  */

      float angle = (linhaDirection.x == 0) ? HALF_PI : atan(linhaDirection.y / linhaDirection.x);
      PVector prevIterationPoint = this.iterationPoint;

      // Espinho Logic
      float iterationPercentage = random(0, 1);
      this.spineCheck();

      for(float f = 0; f < 1.0f; f += map(linhaDirection.mag(), 100, 500, 0.05f, 0.01f) / (float) smoothness){
        this.iterationPoint = new PVector(prevIterationPoint.x + f * linhaDirection.x, prevIterationPoint.y + f * linhaDirection.y);
        Segmento s = new Segmento(iterationPoint.x, iterationPoint.y, this.largura, angle, this.cor);
        

        // Espinho Logic
        if(this.toGetPoint && f >= iterationPercentage){
          this.toGetPoint = false;
          this.doSpine(iterationPoint);
        }

        if(drawing) s.desenhar();
        this.iterationCount++;
      }

      this.iterationPoint = this.mainPoint;

      this.posAngle = angle;
    }
  }

  void resetSpine(){
    lastEspinhoFrame = this.iterationCount;
    espinhoMode = "NOVOESPINHO";
    this.toGetPoint = false;
  }
  
  void spineCheck(){
    if((this.iterationCount - lastEspinhoFrame) >= (FRAME_RATE * intervalNextEspinho)){
      lastEspinhoFrame = this.iterationCount;
      if(espinhoMode == "NOVOESPINHO"){
        this.choosedSide = (0.5f < random(0, 1));
        this.toGetPoint = true;
      }
      else this.toGetPoint = true;
    }
  }

  void doSpine(PVector p){
    /**
      Se for para gerar um novo espinho, então:
    * entra-se no modo "STOPESPINHO" (pq vai ser colocado o inicio)
    * consequentemente, o intervalo para o final do espinho, é gerado aleatoriamente com os possiveis valores referenciados para o intervalo de finalização de um espinho

      Se for para terminar o espinho, então:
    * entra-se em "NOVOESPINHO" (pq acabou de se colocar o final de um)
    * o intervalo, será maior e gerado aleatoriamente
    */
    int k = -1;
    if(espinhoMode == "NOVOESPINHO"){
      this.firstForEspinho = p;
      espinhoMode = "STOPESPINHO";
      k = 1;
    }
    else{
      this.nextForEspinho = p;
      espinhoMode = "NOVOESPINHO";
      k = 0;

      PVector direction = directionVector(this.firstForEspinho, this.nextForEspinho);
      PVector normalDirection = new PVector(direction.y, -1 * direction.x);
      float norma = random(normalInterval[0], normalInterval[1]);
      PVector normalNewDirection = normalDirection.normalize().mult(((choosedSide) ? 1 : -1) * norma);

      PVector midP = midPoint(firstForEspinho, nextForEspinho).add(normalNewDirection);

      Espinho e = new Espinho(this.firstForEspinho, this.nextForEspinho, midPoint(firstForEspinho, nextForEspinho).add(normalNewDirection));
      e.desenhar();
    }

    genIntervalSpine(k);
  }

  void genIntervalSpine(int k){
    intervalNextEspinho = random(
      intervalBetweenEspinhoGen[k][0],
      intervalBetweenEspinhoGen[k][1]
    );
  }
}
