import themidibus.*;
import java.util.Collections;
import java.util.Timer;
import java.util.TimerTask;
import javax.sound.midi.*;
import de.voidplus.leapmotion.*;
import java.io.*;
import javax.sound.midi.MidiEvent;
import javax.sound.midi.MidiMessage;
import javax.sound.midi.MidiSystem;
import javax.sound.midi.Sequence;
import javax.sound.midi.ShortMessage;
import javax.sound.midi.Track;
import controlP5.*;
import ddf.minim.*;
import processing.sound.*;

//variables for GUI-------------------------------------------
// Main GUI controls
ControlP5 cp5; 
RadioButton outputSelectionButton;
RadioButton waveSelectionButton;
int outputSelection = 1;
int waveSelection = 1;
Textlabel selectionLabel;
Textlabel waveLabel;
//variables for the leap motion--------------------------------
LeapMotion leap;
int PITCH_MIN = 60;
//int PITCH_MAX = 108;
int PITCH_MAX = 83;
int VELOCITY_MIN = 1;
int VELOCITY_MAX = 127;
int NUM_CHANNELS = 10;
int HISTORY_LENGTH = 2;
int FINGER_SENSITIVITY = 20;
ArrayList<ArrayList<PVector>> finger_vectors = new ArrayList<ArrayList<PVector>>();

//variables for the keybord--------------------------------
PImage photo;
int keyboardWidth = 1200;
int singleKeyWidth = keyboardWidth / 7;
int whiteKeyNumber = 7;
int blackKeyNumber = 5;
ArrayList<float[]> previousKey = new ArrayList<float[]>();
ArrayList<float[]> tappedKey = new ArrayList<float[]>();
ArrayList<float[]> currentKey = new ArrayList<float[]>();
float[][] position_key;
float axis_x;
float axis_y;

//variables for the sound-----------------------------------

MidiBus bus;
Timer timer;
//NoteTask task;
Minim minim;
AudioPlayer masterAudioPlayer;
AudioPlayer masterAudioPlayer1;
AudioPlayer masterAudioPlayer2;
AudioPlayer masterAudioPlayer3;
AudioPlayer masterAudioPlayer4;
int samplingRate = 44100;
boolean GenerateSound = false;
float duration = 3;
//------------------
int pitch;
float frequent;
float amp;
SinOsc sinOsc;
Env env; 
// Times and levels for the ASR envelope
float attackTime = 0.001;
float sustainTime = 0.04;
float sustainLevel = 0.6;
float releaseTime = 0.4;
// Set the note trigger
int trigger = 0; 
Music music = new Music();

//variables for the control flag--------------------------------
int method = 1;//1-piano 2-sound generate
int sound = 1; // 1-sine
boolean genrateSound = false;

void setup() {
  //set up background canvas-----------------------------------
  size(1200, 360, P3D);
  stroke(0);
  photo = loadImage("test.jpg");
  //set up buttons for output options--------------------------
  cp5 = new ControlP5(this);
   //set up buttons for output options
  cp5.addTextlabel("label_1").setText("Piano Imitation").setPosition(10, 0).setColorValue(0xffffffff).setFont(createFont("Arial", 36)).getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER);
  cp5.addTextlabel("label_2").setText("Options").setPosition(950, 10).setColorValue(0xffffffff).setFont(createFont("Arial", 20)); 
  selectionLabel = cp5.addTextlabel(" ").setPosition(15, 40).setColor(0xffffffff).setFont(createFont("Arial", 18));
  outputSelectionButton = cp5.addRadioButton("outputSelectionButton")
    .setPosition(1035, 10)
    .setSize(18, 18)
    .setItemsPerRow(3)
    .setSpacingColumn(33)
    .setSpacingRow(5)
    .setColorBackground(0xffffffff)
    .setColorForeground(0xffffff00)
    .setColorActive(0xffffff00)
    .setNoneSelectedAllowed(false);
    
    for(int i = 1; i <= 2; ++i) {
        outputSelectionButton.addItem("s"+str(i), i);
    }
    for(Toggle t:outputSelectionButton.getItems()) {
        t.getCaptionLabel().setColor(0xffffffff).setFont(createFont("Arial", 14, true));
    }
    outputSelectionButton.activate(outputSelection - 1);
    //set up buttons for different types of waves
   cp5.addTextlabel("label_3").setText("Waves").setPosition(952, 40).setColorValue(0xffffffff).setFont(createFont("Arial", 18));
   waveLabel = cp5.addTextlabel(" ").setPosition(950, 40).setColor(0xffffffff).setFont(createFont("Arial", 20));
   waveSelectionButton = cp5.addRadioButton("waveSelectionButton")
    .setPosition(1035, 40)
    .setSize(18, 18)
    .setItemsPerRow(3)
    .setSpacingColumn(33)
    .setSpacingRow(5)
    .setColorBackground(0xffffffff)
    .setColorForeground(0xffffff00)
    .setColorActive(0xffffff00)
    .setNoneSelectedAllowed(false);
   
    for(int i = 1; i <= 3; ++i) {
        waveSelectionButton.addItem("w"+str(i), i);
    }
    for(Toggle t:waveSelectionButton.getItems()) {
        t.getCaptionLabel().setColor(0xffffffff).setFont(createFont("Arial", 14, true));
    }
    waveSelectionButton.activate(waveSelection - 1);
  //----------------------------------
  
  position_key = new float[5][2];
  leap = new LeapMotion(this); 

  for ( int x = 0; x < NUM_CHANNELS; x++ ) {
    finger_vectors.add(new ArrayList<PVector>());
  }
  
  // Create sin wave and envelope 
  //sinOsc = new SinOsc(this);
  //env  = new Env(this);
  
  addShutdownHook();
  
  
}


void draw() {
  cursor();
  //---------------------------------------------------------------------------------------------
  background(photo);
  int fps = leap.getFrameRate();
  //frameRate(fps);
 // 
 for (Hand hand : leap.getHands() ) {
    hand.draw();
    int temp = 0;
    for (Finger finger : hand.getFingers()) {
      if(temp == 1 || temp == 3) {
        position_key[temp][0] = 0;
        position_key[temp][1] = 0;  
        temp++;
        continue;
      }
      PVector pos = finger.getPosition();
      position_key[temp][0] = pos.x;
      position_key[temp][1] = pos.y;
      temp++;
    }
  }
  camera(width / 2, height/2 - 200, (height/2) / tan(PI/6), width/2, height/2, -300, 0, 1, 0);
  //Detect hands. Here we just store information for one hand.
  
  
  //println("begin to simulate the piano");

  judgeTappedKey(position_key);
  //Draw keyboard according to arraylist 'tappedKey'.
  drawKeyboard(tappedKey);
  //println("tappedKey");
  println("Current size is: " +currentKey.size());
  
  
  for(float[] current : currentKey) {
    boolean dup= false;
    //println("11111111111");
    for(float[] previous : previousKey) {
     // println("2222222222222");
      if(current[0]==previous[0]){
        dup = true;
        break;
      }
      
    }
    println("dup: "+dup);
      if (!dup) {
        int key_num = (int)current[0];
        println("key_num is :"+ key_num);
        println("begin to generate the music");
        
        //music.music(key_num);
        minim = new Minim(this);
        
         
        if(method == 1){
          //playing the piano key
          switch(key_num){
            case -3:
                masterAudioPlayer1 = minim.loadFile("28-C.mp3");
                masterAudioPlayer1.play();
                masterAudioPlayer1 = null;
                System.gc();
                
                break;
            case 4:
                masterAudioPlayer2 = minim.loadFile("29-C#.mp3");
                masterAudioPlayer2.play();
                masterAudioPlayer2 = null;
                System.gc();
                break;
            case -2:
                masterAudioPlayer3 = minim.loadFile("30-D.mp3");
                masterAudioPlayer3.play();
                masterAudioPlayer3 = null;
                System.gc();
                break;
            case 5:
                masterAudioPlayer4 = minim.loadFile("31-D#.mp3");
                masterAudioPlayer4.play();
                masterAudioPlayer4 = null;
                System.gc();
                break;
            case -1:
                masterAudioPlayer1 = minim.loadFile("32-E.mp3");
                masterAudioPlayer1.play();
                masterAudioPlayer1 = null;
                System.gc();
                break;
            case -0:
                masterAudioPlayer2 = minim.loadFile("33-F.mp3");
                masterAudioPlayer2.play();
                masterAudioPlayer2 = null;
                System.gc();
                break;
            case 6:
                masterAudioPlayer3 = minim.loadFile("34-F#.mp3"); 
                masterAudioPlayer3.play();
                masterAudioPlayer3 = null;
                System.gc();
                break;
            case 1:
                masterAudioPlayer4 = minim.loadFile("35-G.mp3"); 
                masterAudioPlayer4.play();
                masterAudioPlayer4 = null;
                System.gc();
                break;
            case 7:
                masterAudioPlayer1 = minim.loadFile("36-G#.mp3"); 
                masterAudioPlayer1.play();
                masterAudioPlayer1 = null;
                System.gc();
                break;
            case 2:
                masterAudioPlayer2 = minim.loadFile("37-A.mp3"); 
                masterAudioPlayer2.play();
                masterAudioPlayer2 = null;
                System.gc();
                break;
            case 8:
                masterAudioPlayer3 = minim.loadFile("38-A#.mp3"); 
                masterAudioPlayer3.play();
                masterAudioPlayer3 = null;
                System.gc();
                break;
            case 3:
                masterAudioPlayer4 = minim.loadFile("39-B.mp3");
                masterAudioPlayer4.play();
                masterAudioPlayer4 = null;
                System.gc();
                break;
            default:
                break;
          }
        }
        else{
          
        if(genrateSound == true){
          music.music(sound);
        }  
        
        genrateSound = false;
          
        switch(key_num){
            case -3:
                masterAudioPlayer1 = minim.loadFile("tempSound(-3).wav");
                masterAudioPlayer1.play();
                masterAudioPlayer1 = null;
                System.gc();
                
                break;
            case 4:
                masterAudioPlayer2 = minim.loadFile("tempSound(4).wav");
                masterAudioPlayer2.play();
                masterAudioPlayer2 = null;
                System.gc();
                break;
            case -2:
                masterAudioPlayer3 = minim.loadFile("tempSound(-2).wav");
                masterAudioPlayer3.play();
                masterAudioPlayer3 = null;
                System.gc();
                break;
            case 5:
                masterAudioPlayer4 = minim.loadFile("tempSound(5).wav");
                masterAudioPlayer4.play();
                masterAudioPlayer4 = null;
                System.gc();
                break;
            case -1:
                masterAudioPlayer1 = minim.loadFile("tempSound(-1).wav");
                masterAudioPlayer1.play();
                masterAudioPlayer1 = null;
                System.gc();
                break;
            case -0:
                masterAudioPlayer2 = minim.loadFile("tempSound(0).wav");
                masterAudioPlayer2.play();
                masterAudioPlayer2 = null;
                System.gc();
                break;
            case 6:
                masterAudioPlayer3 = minim.loadFile("tempSound(6).wav"); 
                masterAudioPlayer3.play();
                masterAudioPlayer3 = null;
                System.gc();
                break;
            case 1:
                masterAudioPlayer4 = minim.loadFile("tempSound(1).wav"); 
                masterAudioPlayer4.play();
                masterAudioPlayer4 = null;
                System.gc();
                break;
            case 7:
                masterAudioPlayer1 = minim.loadFile("tempSound(7).wav"); 
                masterAudioPlayer1.play();
                masterAudioPlayer1 = null;
                System.gc();
                break;
            case 2:
                masterAudioPlayer2 = minim.loadFile("tempSound(2).wav"); 
                masterAudioPlayer2.play();
                masterAudioPlayer2 = null;
                System.gc();
                break;
            case 8:
                masterAudioPlayer3 = minim.loadFile("tempSound(8).wav"); 
                masterAudioPlayer3.play();
                masterAudioPlayer3 = null;
                System.gc();
                break;
            case 3:
                masterAudioPlayer4 = minim.loadFile("tempSound(3).wav");
                masterAudioPlayer4.play();
                masterAudioPlayer4 = null;
                System.gc();
                break;
            default:
                break;
            }
      }
                    
        //Generate and play sound
      }
    
   
  }
   
  previousKey = (ArrayList<float[]>)currentKey.clone();    
  camera();
}

void addShutdownHook () {
  Runtime.getRuntime().addShutdownHook(new Thread(new Runnable() {
    public void run () {
      System.out.println("Shutting Down");
      try {
        for (int x = 0; x <= NUM_CHANNELS; x++) {
          bus.sendMessage(ShortMessage.CONTROL_CHANGE, x, 0x7B, 0);
        }

        bus.close();
        System.out.println("The simulation is finished");
      }
      catch(Exception ex) {
      }
    }
  }
  ));
}



void drawKey() {
  translate(singleKeyWidth, 0);
  box(singleKeyWidth, 80, 300);
}

void drawTappedKey(ArrayList<float[]> tappedKey) {
  for (float[] key : tappedKey) {
    if(key[0] >= -3 && key[0] <=3) {
    fill(255);
    camera(width / 2, -key[1]+140, (height/2) / tan(PI/6),width/2, height/2, -300, 0, 1, 0);
    translate(width/2, height/2, -150);
    translate(key[0] * singleKeyWidth, 0);
    box(singleKeyWidth, 80, 300);
    } else {
      fill(0);
      camera(width / 2, -key[1]+140, (height/2) / tan(PI/6),width/2, height/2, -300, 0, 1, 0);
      translate(width/2, height/2, -150);
      translate(-3.4 * singleKeyWidth, 0);
      if (key[0] == 4) {
        translate(singleKeyWidth, 0);
        box(singleKeyWidth/2, 120, 180);  
      } else if (key[0] == 5) {
        translate(singleKeyWidth*2, 0);
        box(singleKeyWidth/2, 120, 180);  
      } else if (key[0] == 6) {
        translate(singleKeyWidth*4, 0);
        box(singleKeyWidth/2, 120, 180);  
      } else if (key[0] == 7) {
        translate(singleKeyWidth*5, 0);
        box(singleKeyWidth/2, 120, 180);  
      } else if (key[0] == 8) {
        translate(singleKeyWidth*6, 0);
        box(singleKeyWidth/2, 120, 180);  
      } else{

      }    
    }
  }

}

void drawKeyboard(ArrayList<float[]> tappedKey) {
  //Draw black keys
  fill(0);
  translate(width/2, height/2, -150);
  pushMatrix();
  translate(-3.4 * singleKeyWidth, 0);
  for (int i = 4; i <= 8 ;i++ ) {
    Boolean found = false;
    for(float[] key : tappedKey) {
      if (key[0] == i) {
        if (i == 6) {
          translate(singleKeyWidth*2, 0);
          found = true;
          break;
        } else
        translate(singleKeyWidth, 0);
        found = true;
        break;
      } 
    }
    if( !found ) {
      if (i == 6) {
        translate(singleKeyWidth*2, 0);
        box(singleKeyWidth/2, 120, 180);  
      } else {
        translate(singleKeyWidth, 0);
        box(singleKeyWidth/2, 120, 180);
      }
    }
  }
  
  //Draw white keys
  fill(255);
  popMatrix();
  translate(-4 * singleKeyWidth, 0);
  
  for (int i = -3; i <= 3; i++) {
    Boolean found = false;  
    for(float[] key : tappedKey) {
      if(key[0] == i) {
        translate(singleKeyWidth,0);
        found = true;
        break;
      }
    }
  if( !found )
    drawKey();
  }
  
  drawTappedKey(tappedKey);
  camera(width / 2, height/2 - 200, (height/2) / tan(PI/6), width/2, height/2, -300, 0, 1, 0);
  currentKey = (ArrayList<float[]>)tappedKey.clone();
  tappedKey.clear();
}


void judgeTappedKey(float[][] position) {
  for (int i = 0 ; i < 5; i++) {
    if(position[i][1] > height/2) {
      float[] a = new float[2];
      if(position[i][0] > 0 && position[i][0] < 0 + 0.75 * singleKeyWidth) {
        a[0] = -3;
        a[1] = position[i][1];
        tappedKey.add(a);
      }
      else if(position[i][0] > 0 + 0.75 * singleKeyWidth && position[i][0] < 0 + 1.25 * singleKeyWidth) {
        a[0] = 4;
        a[1] = position[i][1];
        tappedKey.add(a);
      }
      else if(position[i][0] > 0 + 1.25 * singleKeyWidth && position[i][0] < 0 + 1.75 * singleKeyWidth) {
        a[0] = -2;
        a[1] = position[i][1];
        tappedKey.add(a);
      }
      else if(position[i][0] > 0 + 1.75 * singleKeyWidth && position[i][0] < 0 + 2.25 * singleKeyWidth) {
        a[0] = 5;
        a[1] = position[i][1];
        tappedKey.add(a);
      }
      else if(position[i][0] > 0 + 2.25 * singleKeyWidth && position[i][0] < 0 + 3 * singleKeyWidth) {
        a[0] = -1;
        a[1] = position[i][1];
        tappedKey.add(a);
      }
      else if(position[i][0] > 0 + 3 * singleKeyWidth && position[i][0] < 0 + 3.75 * singleKeyWidth) {
        a[0] = -0;
        a[1] = position[i][1];
        tappedKey.add(a);
      }
      else if(position[i][0] > 0 + 3.75 * singleKeyWidth && position[i][0] < 0 + 4.25 * singleKeyWidth) {
        a[0] = 6;
        a[1] = position[i][1];
        tappedKey.add(a);
      }
      else if(position[i][0] > 0 + 4.25 * singleKeyWidth && position[i][0] < 0 + 4.75 * singleKeyWidth) {
        a[0] = 1;
        a[1] = position[i][1];
        tappedKey.add(a);
      }
      else if(position[i][0] > 0 + 4.75 * singleKeyWidth && position[i][0] < 0 + 5.25 * singleKeyWidth) {
        a[0] = 7;
        a[1] = position[i][1];
        tappedKey.add(a);
      }
      else if(position[i][0] > 0 + 5.25 * singleKeyWidth && position[i][0] < 0 + 5.75 * singleKeyWidth) {
        a[0] = 2;
        a[1] = position[i][1];
        tappedKey.add(a);
      }
      else if(position[i][0] > 0 + 5.75 * singleKeyWidth && position[i][0] < 0 + 6.25 * singleKeyWidth) {
        a[0] = 8;
        a[1] = position[i][1];
        tappedKey.add(a);
      }
      else if(position[i][0] > 0 + 6.25 * singleKeyWidth && position[i][0] < 0 + 7 * singleKeyWidth) {
        a[0] = 3;
        a[1] = position[i][1];
        tappedKey.add(a);
      }
    } else {
    // do noting
    } 
  }
  
}


// This method handle the displayed sound information
void updateOutputSelectonInfo() {
    String result = "";

    switch(outputSelection) {
        case 1: 
        result = "Materials generate sound"; 
        break;
        case 2: 
        result = "Processing generate sound"; 
        
        break;
       // case 3: result = "Abelton Live generate sound"; break;
    }
    
    selectionLabel.setText(result);
}

// Setter and getter
public void setOutputSelection(int outputSelection) {
    this.outputSelection = outputSelection;
}

public int getOutputSelection() {
    return outputSelection;
}

void controlEvent(ControlEvent theEvent){
  if (theEvent.isFrom(outputSelectionButton)) {
          outputSelection = int(theEvent.getGroup().getValue());
          setOutputSelection(outputSelection);
          updateOutputSelectonInfo();
          method =  outputSelection;
          System.out.print(method);
  }else if(theEvent.isFrom(waveSelectionButton)){
          waveSelection = int(theEvent.getGroup().getValue());
          setWaveSelection(waveSelection);
          updateWaveSelectonInfo();
          sound =  waveSelection;
          genrateSound = true;
          System.out.print(sound);
  }
 
}

void updateWaveSelectonInfo() {
    String result = "";

    switch(waveSelection) {
        case 1: 
        result = "Sine wave"; 
        break;
        case 2: 
        result = "Trangle wave"; 
        break;
        case 3: result = "Science Fiction"; break;
    }
    
    selectionLabel.setText(result);
}

// Setter and getter
public void setWaveSelection(int outputSelection) {
    this.waveSelection = outputSelection;
}

public int getWaveSelection() {
    return waveSelection;
}