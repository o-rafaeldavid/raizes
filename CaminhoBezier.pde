class CaminhoBezier{
    private ArrayList<PVector> pontos;
    private ArrayList<PVector[]> listVector;
    private ArrayList<float[]> listAngles;
    private float angleRadius = -1;

    ///
    CaminhoBezier(ArrayList<PVector> pontos){
        if(pontos.size() < 1){
            println("ERRO - A lista de pontos oferecida a um Caminho de Bezier tem que ter 2 ou mais pontos");
            exit();
        }
        this.pontos = pontos;

        listVector = new ArrayList<PVector[]>();
        listAngles = new ArrayList<float[]>();
        float ang = PI / 5;

        for(int i = 1; i < pontos.size(); i++){
            float nextAng = random(0, PI);
            listVector.add(new PVector[]{ pontos.get(i - 1), pontos.get(i) });
            listAngles.add(new float[]{ang - PI, nextAng});

            ang = nextAng;
        }

        this.angleRadius = random(height * 0.1f, height * 0.5f);
    }

    ///
    void debugBezier(){
        if(showDebugCaminhoVirtual){
            pushStyle();
                noFill();
                stroke(255, 0, 0);
                strokeWeight(1);
                beginShape();
                    for(int i = 0; i < this.listVector.size(); i++){
                        PVector[] vectors = this.listVector.get(i);
                        float[] angs = this.listAngles.get(i);
                        vertex(vectors[0].x, vectors[0].y);
                        bezierVertex(
                            vectors[0].x + this.angleRadius * cos(angs[0]), vectors[0].y + this.angleRadius * sin(angs[0]),
                            vectors[1].x + this.angleRadius * cos(angs[1]), vectors[1].y + this.angleRadius * sin(angs[1]),
                            vectors[1].x, vectors[1].y
                        );
                    }
                endShape();
            popStyle();
        }
    }

    void debugLinhas(){
        pushStyle();
            noFill();
            stroke(0, 255, 255);
            strokeWeight(1);
            beginShape();
                for(int i = 0; i < this.listVector.size(); i++){
                    PVector[] vectors = this.listVector.get(i);
                    line(vectors[0].x, vectors[0].y, vectors[1].x, vectors[1].y);
                }
            endShape();
        popStyle();
    }

    void debugPontos(){
        pushStyle();
            noFill();
            stroke(255);
            strokeWeight(10);
            pontos.forEach(
                (bp) -> point(bp.x, bp.y)
            );
        popStyle();
    }

    ///
    private void checkGetFactor(float f){
        if(f < 0 || f > 1){
            println("ERRO - O parâmetro utilizado no método getPoint de um objeto CaminhoBezier tem de ser entre 0 e 1 - não pode ser: " + f);
            exit();
        }
    }

    PVector getPointLine(float f){
        checkGetFactor(f);

        float entrePontos = constrain(map(f, 0, 1, 0, pontos.size() - 1), 0, pontos.size() - 1);
        int indexLinha = (entrePontos < pontos.size() - 1) ? int(entrePontos) : pontos.size() - 2;

        PVector[] linhas = listVector.get(indexLinha);
        PVector dirLinha = directionVector(linhas[0], linhas[1]);

        float maxLen = dirLinha.mag();
        float factorLinha = (entrePontos < pontos.size() - 1) ? map(entrePontos, indexLinha, indexLinha + 1, 0, 1) : 1;

        PVector firstPSave = new PVector(linhas[0].x, linhas[0].y);
        PVector dirLinhaSave = new PVector(dirLinha.x, dirLinha.y);
        firstPSave.add(dirLinhaSave.normalize().mult(factorLinha * maxLen));
        return firstPSave;

    }

    PVector[] getPointsBetweenFactor(float f){
        checkGetFactor(f);

        float entrePontos = constrain(map(f, 0, 1, 0, pontos.size() - 1), 0, pontos.size() - 1);
        int indexLinha = (entrePontos < pontos.size() - 1) ? int(entrePontos) : pontos.size() - 2;

        PVector[] linhas = this.listVector.get(indexLinha);

        return linhas;
    }

    PVector getPointBezier(float f){
        checkGetFactor(f);

        float entrePontos = constrain(map(f, 0, 1, 0, pontos.size() - 1), 0, pontos.size() - 1);
        int indexLinha = (entrePontos < pontos.size() - 1) ? int(entrePontos) : pontos.size() - 2;

        PVector[] linhas = this.listVector.get(indexLinha);
        float[] angs = this.listAngles.get(indexLinha);

        float factorLinha = (entrePontos < pontos.size() - 1) ? map(entrePontos, indexLinha, indexLinha + 1, 0, 1) : 1;
        /* println(factorLinha); */

        float x = bezierPoint(
            linhas[0].x,
            linhas[0].x + this.angleRadius * cos(angs[0]),
            linhas[1].x + this.angleRadius * cos(angs[1]),
            linhas[1].x,
            factorLinha
        );

        float y = bezierPoint(
            linhas[0].y,
            linhas[0].y + this.angleRadius * sin(angs[0]),
            linhas[1].y + this.angleRadius * sin(angs[1]),
            linhas[1].y,
            factorLinha
        );

        /* println(x, y); */

        return new PVector(x, y);

    }

    ArrayList<PVector> getAllPoints(){
        return pontos;
    }
}