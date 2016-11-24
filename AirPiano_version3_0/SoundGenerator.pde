
//generate sound    
class SoundGenerator implements Runnable {
    private int samplingRate = 44100; // Number of samples used for 1 second of sound
    private int nyquistFrequency = samplingRate / 2; // Nyquist frequency

    private AudioSamples soundSamples;   // the sound samples (two channels)
    private int sound;
    private float amplitude = 1.0;
    private float frequency = 256;
    private float duration = 1;  // the duration of the sound to be generated (in seconds)

    private float minValue = -1.0;
    private float maxValue = 1.0;

    // Constructors
    SoundGenerator(int sound, float amplitude, float frequency, float duration, int samplingRate) {
        this.samplingRate = samplingRate;
        this.nyquistFrequency = samplingRate / 2;
        this.sound = sound;
        this.amplitude = amplitude;
        this.frequency = frequency;
        this.duration = duration;
        soundSamples = new AudioSamples(duration, samplingRate);
    }

    SoundGenerator(int sound, float amplitude, float frequency, float duration) {
        this.sound = sound;
        this.amplitude = amplitude;
        this.frequency = frequency;
        this.duration = duration;
        soundSamples = new AudioSamples(duration, samplingRate);
    }

    SoundGenerator(int sound, float amplitude, float frequency) {
        this.sound = sound;
        this.amplitude = amplitude;
        this.frequency = frequency;
        soundSamples = new AudioSamples(duration, samplingRate);
    }

    // This function is called when using thread
    public void run() {
        generateSound(sound, amplitude, frequency, duration);
    }

    // Setter and getter
    public void setSound(int sound) {
        this.sound = sound;
    }

    public int getSound() {
        return sound;
    }

    public void setAmp(float amplitude) {
        this.amplitude = amplitude;
    }

    public float getAmp() {
        return amplitude;
    }

    public void setFrequency(float frequency) {
        this.frequency = frequency;
    }

    public float getFrequency() {
        return frequency;
    }

    public AudioSamples getGeneratedSound() {
        return soundSamples;
    }

    // This function generates an individual sound, using the paramters passed into the constructor
    public AudioSamples generateSound() {
        return this.generateSound(sound, amplitude, frequency, duration);
    }

    public AudioSamples generateSound(int sound, float amplitude, float frequency) {
        return this.generateSound(sound, amplitude, frequency, duration);
    }

    // This function generates an individual sound
    public AudioSamples generateSound(int sound, float amplitude, float frequency, float duration) {
        // Reset audio samples before generating audio
        soundSamples.clear();

        switch(sound) {
            case (1): generateSineInTimeDomain(amplitude, frequency, duration); break;
            case (2): generateSquareInTimeDomain(amplitude, frequency, duration); break;
            case (3): generateSquareAdditiveSynthesis(amplitude, frequency, duration); break;
            case (4): generateSawtoothInTimeDomain(amplitude, frequency, duration); break;
            case (5): generateSawtoothAdditiveSynthesis(amplitude, frequency, duration); break;
            case (6): generateTriangleAdditiveSynthesis(amplitude, frequency, duration); break;
            case (7): generateBellFMSynthesis(amplitude, frequency, duration); break;
            case (8): generateKarplusStrongSound(amplitude, frequency, duration); break;
            case (9): generateWhiteNoise(amplitude, frequency, duration); break;
            case(10): generateFourSineWave(amplitude, frequency, duration); break;
            case(11): generateRepeatingNarrowPulse(amplitude, frequency, duration); break;
            case(12): generateTriangleInTimeDomain(amplitude, frequency, duration); break;
            case(13): generateSciFiSound(amplitude, frequency, duration); break;
            case(14): generateKarplusStrongSound2(amplitude, frequency, duration); break;
            case(15): generateAxB(1, 1, amplitude, frequency, duration); break;
            case(16): generateAxB(1, 5, amplitude, frequency, duration); break;
            case(17): generateAxB(1, 10, amplitude, frequency, duration); break;
            case(18): generateAxB(4, 4, amplitude, frequency, duration); break;
            case(19): generateAxB(5, 6, amplitude, frequency, duration); break;
            
        }

        return soundSamples;
    }

    // This function generates a sine wave using the time domain method
    private void generateSineInTimeDomain(float amplitude, float frequency, float duration) {
        int samplesToGenerate = int(duration * samplingRate);
        for(int i = 0; i < samplesToGenerate && i < soundSamples.totalSamples; ++i) {
            float currentTime = float(i) / samplingRate;
            soundSamples.leftChannelSamples[i] = amplitude * sin(TWO_PI * frequency * currentTime);
            soundSamples.rightChannelSamples[i] = soundSamples.leftChannelSamples[i];
        }
        
    }
// This function generates a square wave -_-_ using the time domain method
    private void generateSquareInTimeDomain(float amplitude, float frequency, float duration) {
        int samplesToGenerate = int(duration * samplingRate);
        float oneCycle = samplingRate / frequency;
        float halfCycle = oneCycle / 2;
        for(int i = 0; i < samplesToGenerate && i < soundSamples.totalSamples; ++i) {
            float whereInCycle = i % int(oneCycle);
            if (whereInCycle < halfCycle) {
                soundSamples.leftChannelSamples[i] = amplitude * maxValue;
                soundSamples.rightChannelSamples[i] = soundSamples.leftChannelSamples[i];
            } else {
                soundSamples.leftChannelSamples[i] = amplitude * minValue;
                soundSamples.rightChannelSamples[i] = soundSamples.leftChannelSamples[i];
            }
        }
    }

    // This function generates a square wave -_-_ using the additive synthesis method
    private void generateSquareAdditiveSynthesis(float amplitude, float frequency, float duration) {
        int samplesToGenerate = int(duration * samplingRate);

        for(int i = 0; i < samplesToGenerate && i < soundSamples.totalSamples; ++i) {
            float sampleValue = 0;
            float currentTime = float(i) / samplingRate;
            for(int wave = 1; wave * frequency < nyquistFrequency; wave += 2) {
                sampleValue += (1.0 / wave) * sin(wave * TWO_PI * frequency * currentTime);
            }
            soundSamples.leftChannelSamples[i] = amplitude * sampleValue;
            soundSamples.rightChannelSamples[i] = soundSamples.leftChannelSamples[i];
        }
    }

    // This function generates a sawtooth wave /|/| using time domain method
    private void generateSawtoothInTimeDomain(float amplitude, float frequency, float duration) {
        int samplesToGenerate = int(duration * samplingRate);
        float oneCycle = samplingRate / frequency;
        for(int i = 0; i < samplesToGenerate && i < soundSamples.totalSamples; ++i) {
            float sampleValue = int(i % oneCycle) / oneCycle * 2.0f - 1.0f;
            soundSamples.leftChannelSamples[i] = amplitude * sampleValue;
            soundSamples.rightChannelSamples[i] = soundSamples.leftChannelSamples[i];
        }
    }

    // This function generates a sawtooth wave \|\| using the additive synthesis method
    private void generateSawtoothAdditiveSynthesis(float amplitude, float frequency, float duration) {
        /*** added by bwuai 2016-10-07 ***/
        int samplesToGenerate = int(duration * samplingRate);
        
        for(int i = 0;i < samplesToGenerate && i < soundSamples.totalSamples; i++){
            float sampleValue = 0;
            float currentTime = float(i) / samplingRate;
            for(int wave = 1;wave * frequency < nyquistFrequency; wave+=1){
                sampleValue += ((1.0 / wave) * sin(wave * TWO_PI * frequency * currentTime));
            }
            soundSamples.leftChannelSamples[i] = amplitude * sampleValue ;    
            soundSamples.rightChannelSamples[i] = soundSamples.leftChannelSamples[i];
        }
        
    }

    // This function generates a triangle wave \/\/ using the additive synthesis method (with cosine)
    private void generateTriangleAdditiveSynthesis(float amplitude, float frequency, float duration) {
        /*** added by bwuai 2016-10-07 ***/
        int samplesToGenerate = int(duration * samplingRate);
        
        for(int i = 0;i < samplesToGenerate && i < soundSamples.totalSamples; i++){
            float sampleValue = 0;
            float currentTime = float(i) / samplingRate;
            for(int wave = 1;wave * frequency < nyquistFrequency; wave+=2){
                sampleValue += ((1.0 / (wave * wave)) * cos(wave * TWO_PI * frequency * currentTime));
            }
            soundSamples.leftChannelSamples[i] = amplitude * sampleValue ;    
            soundSamples.rightChannelSamples[i] = soundSamples.leftChannelSamples[i];
        }

    }

    // This function generates a 'bell' sound using FM synthesis
    private void generateBellFMSynthesis(float amplitude, float frequency, float duration) {
        /*** added by bwuai 2016-10-07 ***/
        int samplesToGenerate = int(duration * samplingRate);
        float fm_freq = 280;
        float am = 3.0;
        
        for(int i = 0;i < samplesToGenerate && i < soundSamples.totalSamples; i++){
            float sampleValue = 0;
            float currentTime = float(i) / samplingRate;
            
            sampleValue = sin(TWO_PI * currentTime * 100 + am * sin(TWO_PI * fm_freq * currentTime)); //frequency fixed 100
            
            soundSamples.leftChannelSamples[i] = amplitude * sampleValue ;    
            soundSamples.rightChannelSamples[i] = soundSamples.leftChannelSamples[i];
        }
        
    }

    // This function generate a sound using Karplus-Strong algorithm
    private void generateKarplusStrongSound(float amplitude, float frequency, float duration) {
        /*** added by bwuai 2016-10-07 ***/
        float sampleValue = 0.0;
        int samplesToGenerate = int(duration * samplingRate);
        /*
        //first, fill the 5 seconds with a sawtooth signal
        
        float oneCycle = samplingRate / 256;
        for(int i = 0; i < samplesToGenerate && i < soundSamples.totalSamples; i++) {
            sampleValue = int(i % oneCycle) / oneCycle * 2.0f - 1.0f;
            soundSamples.leftChannelSamples[i] = amplitude * sampleValue;         
        }
        */
        //first, fill the 5 seconds with a sine signal
        for(int i = 0; i < samplesToGenerate && i < soundSamples.totalSamples; i++) {
            float currentTime = float(i) / samplingRate;
            sampleValue = sin(TWO_PI * 256 * currentTime);
            soundSamples.leftChannelSamples[i] = amplitude * sampleValue;
            soundSamples.rightChannelSamples[i] = soundSamples.leftChannelSamples[i];
        }        
                
        //second, apply the basic KS algorithm
        //int delay = 1000;
        //int delay = (int)frequency;
        int delay = (int)(samplingRate/frequency);
        for(int i = delay + 1; i < samplesToGenerate && i < soundSamples.totalSamples; i++){
            soundSamples.leftChannelSamples[i] = amplitude * 0.5 * (soundSamples.leftChannelSamples[i - delay] + soundSamples.leftChannelSamples[i - delay - 1]);   
            soundSamples.rightChannelSamples[i] = soundSamples.leftChannelSamples[i];
        }            
    }

    // This function generats a white noise
    private void generateWhiteNoise(float amplitude, float frequency, float duration) {
        /*** added by bwuai 2016-10-07 ***/
        int samplesToGenerate = int(duration * samplingRate);
        
        for(int i = 0; i < samplesToGenerate && i < soundSamples.totalSamples; i++) {
            float sampleValue = random(-1 , 1);
            soundSamples.leftChannelSamples[i] = amplitude * sampleValue;
            soundSamples.rightChannelSamples[i] = soundSamples.leftChannelSamples[i];
        }
    }

    // This function generates '3 sine wave' sound
    private void generateFourSineWave(float amplitude, float frequency, float duration) {
        // Generate the 3 sine waves by adding the sine waves at the correct frequency and
        // correct amplitude. The fundamental frequency comes from the variable 'frequency'.

        /*** added by bwuai 2016-10-07 ***/
        int samplesToGenerate = int(duration * samplingRate);
        
        for(int i = 0; i < samplesToGenerate && i < soundSamples.totalSamples; i++) {
            float currentTime = float(i) / samplingRate;
            float sampleValue = sin(TWO_PI * frequency * currentTime) + 
            0.8 * sin(TWO_PI * 3 * frequency * currentTime) + 0.8 * sin(TWO_PI * 4 * frequency * currentTime);
            soundSamples.leftChannelSamples[i] = amplitude * sampleValue;
            soundSamples.rightChannelSamples[i] = soundSamples.leftChannelSamples[i];
        }

    }

    // This function generates a repeating narrow pulse
    private void generateRepeatingNarrowPulse(float amplitude, float frequency, float duration) {
        /*** added by bwuai 2016-10-07 ***/
        int samplesToGenerate = int(duration * samplingRate);
        int oneCycle = (int)(samplingRate / frequency);
        float sampleValue = 0.0;
        
        for(int i = 0; i < samplesToGenerate && i < soundSamples.totalSamples; i++) {
            if(i%oneCycle == 0){
            sampleValue = 1;
            }
            else if(i%oneCycle == 1){
            sampleValue = -1;
            }
            else {
            sampleValue = 0;            
            }
            soundSamples.leftChannelSamples[i] = amplitude * sampleValue ;
            soundSamples.rightChannelSamples[i] = soundSamples.leftChannelSamples[i];
        }
        
    }

    // This function generates a triangle wave using the time domain method
    private void generateTriangleInTimeDomain(float amplitude, float frequency, float duration) {
        /*** added by bwuai 2016-10-07 ***/
        int samplesToGenerate = int(duration * samplingRate);
        float oneCycle = samplingRate / frequency;
        float halfOneCycle = oneCycle / 2;
        float sampleValue = 0.0;
        
        for(int i = 0;i < samplesToGenerate && i < soundSamples.totalSamples; i++){
            int cyclePosition = i % int(oneCycle);
            float cycleFraction = cyclePosition / oneCycle;
            
            if(cyclePosition < halfOneCycle){
               sampleValue = 2 * (1 - (cycleFraction / 0.5)) + (-1);
            }
            else {
               sampleValue = 2 * ((cycleFraction - 0.5) / 0.5) + (-1);
            }
            soundSamples.leftChannelSamples[i] = amplitude * sampleValue ;
            soundSamples.rightChannelSamples[i] = soundSamples.leftChannelSamples[i];
        }
        
    }

    // This function generates a science fiction movie sound using FM synthesis
    private void generateSciFiSound(float amplitude, float frequency, float duration) {
         /*** added by bwuai 2016-10-07 ***/
        int samplesToGenerate = int(duration * samplingRate);
        float fm_freq = 15;
        float am = 3.0;
        float sampleValue = 0.0;
        float currentTime = 0.0;
                
        for(int i = 0; i < samplesToGenerate && i < soundSamples.totalSamples; i++){
            currentTime = float(i) / samplingRate;            
            sampleValue = sin(TWO_PI * currentTime * 250 + am * sin(TWO_PI * fm_freq * currentTime)); //frequency fixed 250          
            soundSamples.leftChannelSamples[i] = amplitude * sampleValue ;    
            soundSamples.rightChannelSamples[i] = soundSamples.leftChannelSamples[i];
        }
    }

    // This function generate a sound using Karplus-Strong algorithm
    private void generateKarplusStrongSound2(float amplitude, float frequency, float duration) {
        /*** added by bwuai 2016-10-07 ***/
        
        int samplesToGenerate = int(duration * samplingRate);
        float sampleValue = 0.0;
       
        //first, fill the 5 seconds with a sine signal
        for(int i = 0; i < samplesToGenerate && i < soundSamples.totalSamples; i++) {
            float currentTime = float(i) / samplingRate;
            sampleValue = sin(TWO_PI * 256 * currentTime);
            soundSamples.leftChannelSamples[i] = amplitude * sampleValue;
            soundSamples.rightChannelSamples[i] = soundSamples.leftChannelSamples[i];
        }
         
         /*
         for(int i = 0; i < samplesToGenerate && i < soundSamples.totalSamples; i++) {
            sampleValue = random(-1 , 1);
            soundSamples.leftChannelSamples[i] = amplitude * sampleValue;
            soundSamples.rightChannelSamples[i] = soundSamples.leftChannelSamples[i];
        }
         
        float oneCycle = samplingRate / 256;
        for(int i = 0; i < samplesToGenerate && i < soundSamples.totalSamples; i++) {
            sampleValue = int(i % oneCycle) / oneCycle * 2.0f - 1.0f;
            soundSamples.leftChannelSamples[i] = amplitude * sampleValue;      
            soundSamples.rightChannelSamples[i] = soundSamples.leftChannelSamples[i];
        }
        */
        
        //second, apply the basic KS algorithm
        
        double blend = 0.5;
        //int delay = (int)frequency;
        int delay = 200;
        double t = 0.0;
        for(int i = delay + 1; i < samplesToGenerate && i < soundSamples.totalSamples; i++){
            t = Math.random() ;
            if(t <= blend){
            soundSamples.leftChannelSamples[i] = amplitude * 0.5 * (soundSamples.leftChannelSamples[i - delay] + soundSamples.leftChannelSamples[i - delay - 1]);               
            soundSamples.rightChannelSamples[i] = soundSamples.leftChannelSamples[i];
            }
            else{
            soundSamples.leftChannelSamples[i] = amplitude * (-0.5) * (soundSamples.leftChannelSamples[i - delay] + soundSamples.leftChannelSamples[i - delay - 1]);             
            soundSamples.rightChannelSamples[i] = soundSamples.leftChannelSamples[i];
            }
       }
    }

    // This function generates a waveform that is the multiplication of another 2 waveforms
    // Use AudioSamples::reMap if needed
    private void generateAxB(int soundA, int soundB, float amplitude, float frequency, float duration) {
        /*** added by bwuai 2016-10-07 ***/
        int samplesToGenerate = int(duration * samplingRate);
        
        AudioSamples soundSamples_A;
        soundSamples_A = generateSound(soundA, amplitude, frequency, duration);
        AudioSamples soundSamples_B;
        soundSamples_B = generateSound(soundB, amplitude, frequency, duration);
        //use boost to control the range 
        soundSamples_A.applyBoost(0,0,0);
        soundSamples_B.applyBoost(0,0,0);
             
        //change the sound range to 0 to 1 , multiply A with B , then turn the final sound to -1 to 1
        for(int i = 0; i < samplesToGenerate && i < soundSamples.totalSamples; i++) {            
            soundSamples.leftChannelSamples[i] = amplitude * ((soundSamples_A.leftChannelSamples[i] / 2 + 0.5) * (soundSamples_B.leftChannelSamples[i] / 2 + 0.5) - 0.5) * 2;
            soundSamples.rightChannelSamples[i] = soundSamples.leftChannelSamples[i];
        }
               
    }

    // You can add your own sound if you want to
    private void generateSound20(float amplitude, float frequency, float duration) {
    }

    // You can add your own sound if you want to
    private void generateSound21(float amplitude, float frequency, float duration) {
    }

    // You can add your own sound if you want to
    private void generateSound22(float amplitude, float frequency, float duration) {
    }

    // You can add your own sound if you want to
    private void generateSound23(float amplitude, float frequency, float duration) {
    }

    // You can add your own sound if you want to
    private void generateSound24(float amplitude, float frequency, float duration) {
    }
}