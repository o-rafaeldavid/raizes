class Segmento{
  public PVector posicao;
  public float largura, direcao, seeingRange = 50;
  //private PVector[] pontosLaterais = new PVector[2];
  public PVector pontoA, pontoB;
  private float angulo;
  private color cor;
  private PMatrix2D rotationMatrix = new PMatrix2D();
  
  //////////////////////////////////////////////////////
  /////
  Segmento(float x, float y, float largura, float direcao, color cor){  
    this.posicao = new PVector(x, y);
    this.largura = largura;
    this.direcao = direcao;
    this.angulo = this.direcao - HALF_PI;
    this.cor = cor;
    this.rotationMatrix.rotate(this.angulo);
    
    float halfLargura = this.largura * 0.5;

    this.pontoA = new PVector(
                      this.posicao.x + halfLargura * cos(this.angulo),
                      this.posicao.y + halfLargura * sin(this.angulo)
    );
    this.pontoB = new PVector(
                      this.posicao.x - halfLargura * cos(this.angulo),
                      this.posicao.y - halfLargura * sin(this.angulo)
    );
    
    queuedSegmentoPontos.add(new PVector[]{this.pontoA, this.pontoB});
  }
  
  void desenhar(){
    pushStyle();
      stroke(cor);
      strokeWeight(pesoLinha);
      lineVector(this.pontoA, this.pontoB);
    popStyle();
  }
}
