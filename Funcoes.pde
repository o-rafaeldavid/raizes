void lineVector(PVector A, PVector B){
  line(A.x, A.y, B.x, B.y);
}

boolean checkColors(color C, color S){
  return (red(C) == red(S)) && (green(C) == green(S)) && (blue(C) == blue(S));
}

PVector directionVector(PVector from, PVector to){
  return new PVector(to.x - from.x, to.y - from.y);
}

PVector midPoint(PVector A, PVector B){
  return new PVector((A.x + B.x) * 0.5f, (A.y + B.y) * 0.5f);
}