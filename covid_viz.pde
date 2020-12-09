import processing.svg.*;
import processing.pdf.*;
import java.util.*;
import java.text.DecimalFormat;

float marginLR;
float marginUD;
float sizeCtrl;
String filename;

final String api_url = "https://api.covid19india.org/data.json";
PFont font;
JSONArray data;

int confirmed[];
int deceased[];
int recovered[];
char choice;
int chi;
String choiceText;
final char[] ch = { 'c', 'd', 'r', 'a' };
final String[] chTxt = { "Confirmed", "Deceased", "Recovered", "All" };

final color colors[] = { color(3, 7, 3), color(55, 6, 23), color(106, 4, 15), color(157, 2, 8), color(208, 0, 0), color(220, 47, 2), color(232, 93, 4), color(244, 140, 6), color(250, 163, 7), color(255, 186, 8) };
final color colors4all[] = { color(232, 93, 4), color(3, 7, 3), color(157, 2, 8) };
ArrayList clrGrp[];

void setup() {
  data = loadJSONObject(api_url).getJSONArray("cases_time_series");
  font = createFont("SourceCodePro-Regular.otf", 20);
  textFont(font);

  chi = 0;
  choice = ch[chi];
  choiceText = chTxt[chi];

  //size(1920, 1080, PDF, "covid-19.pdf");
  //size(1920, 1080, SVG, "covid-19-confirmed.svg");
  //size(1920, 1080, SVG, "covid-19-deceased.svg");
  //size(1920, 1080, SVG, "covid-19-recovered.svg");
  //size(1920, 1080, SVG, "covid-19-all.svg");
  //size(1280, 720, PDF, "covid-19.pdf");
  size(1280, 720);
  //size(1366, 768);
  //size(1920, 1080);
  marginLR = width*0.015;
  marginUD = height*0.05;
  sizeCtrl = 1;
  //sizeCtrl = 1.5;

  confirmed = new int[data.size()];
  deceased = new int[data.size()];
  recovered = new int[data.size()];

  for (int i = 0; i < data.size(); i++) {
    JSONObject obj = data.getJSONObject(i);
    confirmed[i] = Integer.valueOf(obj.getString("totalconfirmed"));
    deceased[i] = Integer.valueOf(obj.getString("totaldeceased"));
    recovered[i] = Integer.valueOf(obj.getString("totalrecovered"));
  }

  smooth(4);
}

void draw() {
  //background(200);
  background(255);

  fill(20);
  textAlign(LEFT);
  textSize(20);
  text("Covid-19", marginLR, marginUD);
  fill(100);
  textSize(15);
  text("India", marginLR, marginUD*1.5);
  textSize(12);
  text(choiceText, marginLR, marginUD*2);
  textSize(10);
  float marR = width-marginLR;
  float marD = height-marginUD+20;
  text("not to scale", marginLR, marD);
  String txtUp = "©2020 athulcvinod";
  String txtDn = "api.covid19india.org";
  textAlign(RIGHT);
  text(txtUp, marR, marD-10);
  text(txtDn, marR, marD);

  push();
  translate(width*0.02, height-(height*0.07));
  switch(choice) {
  case 'c':
    chart(confirmed);
    break;
  case 'd':
    chart(deceased);
    break;
  case 'r':
    chart(recovered);
    break;
  case 'a':
    chart4All();
    break;
  }
  pop();
  if (choice != 'a') {
    showLegends();
  } else {
    showLegends4all();
  }
  //exit();
}

void mousePressed() {
  chi++;
  if (chi >= ch.length) {
    chi = 0;
  }
  choice = ch[chi];
  choiceText = chTxt[chi];
}

void chart4All() {
  if (data != null) {
    strokeWeight(1);
    noFill();
    int alpha = 15;
    int[][] arr_pack = { recovered, deceased, confirmed };
    for (int v = 0; v < arr_pack.length; v++) {
      int[] arr = arr_pack[v];
      for (int i = arr.length-1; i>=0; i--) {
        push();
        stroke(colors4all[v], alpha);
        float size = map(arr[i], 0, maxInt(arr), 0, height - 100);
        translate(
          map(i, 0, arr.length-1, 0, width-(width*0.35)), 
          -i*sizeCtrl
          );
        circle(0, 0, size);
        pop();
      }
    }
  }
}

void chart(int[] values) {
  if (data != null) {
    int strkWt = 1;
    int fillColor = 170;
    int alpha = 20;
    clrGrp = new ArrayList[colors.length];
    for (int i = 0; i < clrGrp.length; i++) {
      clrGrp[i] = new ArrayList();
    }
    for (int i = values.length-1; i>=0; i--) {
      push();
      float size = map(values[i], 0, maxInt(values), 0, height - 100);
      int c = floor(map(values[i], 0, maxInt(values), 0, colors.length - 1));
      stroke(colors[c]);
      clrGrp[c].add(values[i]);
      translate(
        map(i, 0, values.length-1, 0, width-(width*0.35)), 
        -i*sizeCtrl
        );
      strokeWeight(strkWt);
      fill(fillColor, alpha);
      circle(0, 0, size);
      pop();
    }
  }
}

void showLegends() {
  push();
  rectMode(CENTER);
  DecimalFormat formatter = new DecimalFormat("###,###");
  float squareSize = 10;
  float mar = width-(marginLR+squareSize/2);
  //translate(mar, height-35);
  translate(mar, height-marginUD);
  int max[] = new int[colors.length];
  int min[] = new int[colors.length];
  for (int i=0; i<clrGrp.length; i++) {
    max[i] = Collections.max(clrGrp[i]);
    min[i] = Collections.min(clrGrp[i]);
  }
  //println("max: "+Arrays.toString(max));
  //println("min: "+Arrays.toString(min));
  for (int i=0; i<clrGrp.length; i++) {
    float y = -(i+1)*squareSize;
    noStroke();
    fill(colors[i]);
    textSize(8);
    textAlign(RIGHT, CENTER);
    String s = "";
    if (i==clrGrp.length-1) {
      s = "> " + formatter.format(min[i]);
    } else {
      s = formatter.format(min[i]) + " - " + formatter.format(max[i]);
    }
    text(s, -10, y);
    rect(0, y, squareSize, squareSize);
  }
  pop();
}

void showLegends4all() {
  push();
  final String[] chTxt4all = { "Recovered", "Deceased", "Confirmed"};
  rectMode(CENTER);
  float mar = width-marginLR;
  translate(mar, height-marginUD);
  for (int i=0; i<3; i++) {
    float y = -(i+1)*10;
    noStroke();
    fill(colors4all[i]);
    textSize(8);
    textAlign(RIGHT, CENTER);
    text(chTxt4all[i], 0, y);
  }
  pop();
}

int maxInt(int[] arr) {
  int great = Integer.MIN_VALUE;
  for (int n : arr) {
    great = n>great?n:great;
  }
  return great;
}
