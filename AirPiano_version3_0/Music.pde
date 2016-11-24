
class Music{

  
  AudioSamples tempsd;
  AudioSamples ss;
  int note = 0;
  float key;
  String string = null;
  String name = null;
  File f;
  float frequency=0;
  ArrayList<Integer> list = 
new ArrayList<Integer>(){{add(60); add(61);add(62);add(63);add(64);add(65);add(66);add(67);add(68);add(69);add(70);add(71);}} ;

            void music(int sound){
            println(">>>begin to gererate sound:" +sound);

                if(sound == 2){
                 sound += 2;
                }
                if(sound == 3){
                 sound += 10;
                }
                for(int i=0; i< list.size(); i++){
                println(">>>begin to gererate key sound");  
                int note = list.get(i);
                println("note :"+note);
                generateWaveSound(note,sound);
                string = "tempSound("+(i-3)+").wav";
                regenerateSingleSound(tempsd,string);
                tempsd.clear(); 
                }
                                                        
           }


// This function convert MIDI pitch to frequency
    public float MIDIPitchToFreq(int MIDIPitch) {
        float temp = 256.0;

        float pitch21 = 27.5;
        int pitch21Note = 21;
        
        float semitone = MIDIPitch - pitch21Note;
        double ratio = Math.pow(2 , (semitone / 12));
        
        temp = pitch21 * (float)ratio;

        return temp;
    }


void regenerateSingleSound(AudioSamples ss,String string) {
    
    //writingSingleSound = true;
    
    
    
    if(masterAudioPlayer != null) {
        masterAudioPlayer.pause();
    }
   
    String name = "\""+string+"\"";
    println("name: "+name);
    
    WAVFileWriter fw = new WAVFileWriter(string);
    fw.Save(ss.leftChannelSamples, ss.rightChannelSamples, samplingRate);
    
        println(">>>  Finished saving sound... ");
    
    //masterAudioPlayer = minim.loadFile(name);

}

void generateWaveSound(int note, int sound){
  
            float frequency = MIDIPitchToFreq(note);
            //float amp = int(map(diff, FINGER_SENSITIVITY, height/7, VELOCITY_MIN, VELOCITY_MAX)) / 127.0*2;
            float amp = 1;
            //float duration = 2;
            
            println(note,frequency,amp,duration);
            
            
            // Create a new SoundGenerator with parameters of this note
            SoundGenerator sg = new SoundGenerator(sound, amp , frequency, duration, samplingRate);         
            tempsd = sg.generateSound();
            //adding the postprocessing
            tempsd.applyPostProcessing(7);
            tempsd.applyPostProcessing(2);                       
            tempsd.applyPostProcessing(5);
            tempsd.applyPostProcessing(10);
            
            //ss.add(tempsd, 0.5, 0);
            
            
            tempsd.applyPostProcessing(7);
            tempsd.applyPostProcessing(9);
            tempsd.applyPostProcessing(7);
            tempsd.applyPostProcessing(5);
            tempsd.applyPostProcessing(10);

}