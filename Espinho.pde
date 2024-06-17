class Espinho{
    PVector[] pontos = new PVector[3];
    Espinho(PVector first, PVector second, PVector mid){
        this.pontos[0] = first;
        this.pontos[1] = second;
        this.pontos[2] = mid;

        queuedEspinhoPontos.add(pontos);
    }

    void desenhar(){
        pushStyle();
            noStroke();
            fill(dourado);
            beginShape();
                for(int i = 0; i < pontos.length; i++){
                    vertex(pontos[i].x, pontos[i].y);
                }
            endShape(CLOSE);
        popStyle();
    }
}