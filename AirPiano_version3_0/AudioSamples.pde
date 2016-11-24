
class AudioSamples {

  public float duration;
  public int samplingRate;
  public int totalSamples;
  public float[] leftChannelSamples;
  public float[] rightChannelSamples;

  // Constructor
  AudioSamples(float duration, int samplingRate) {
    this.duration = duration;
    this.samplingRate = samplingRate;

    totalSamples = int(duration * samplingRate);
    leftChannelSamples = new float[totalSamples];
    rightChannelSamples = new float[totalSamples];

    clear();
  }

  public void add(AudioSamples other, float stereoPosition, float startPosition) {
    add(other, stereoPosition, startPosition, other.duration);
  }

  // Add anohter AudioSamples to this
  // The input parameters are:
  // - another AudioSamples that to be added to this AudioSamples
  // - the stereo position, in the range [0, 1]. 0 means left only, 0.5 is in the middle and 1 means right only.
  // - the start time, in seconds
  // - the duration, in seconds
  public void add(AudioSamples other, float stereoPosition, float startPosition, float duration) {
    // In this function we add the individual sound samples to the complete music sequence samples.
    // Another way to think about it is that we are adding a single musical note to the complete music sequence.

    int startSample = int(startPosition * samplingRate);
    int samplesToCopy = int(duration * samplingRate);

    if (startSample >= totalSamples) return;

    float leftVol = 1.0 - stereoPosition;
    float rightVol = stereoPosition;

    for (int i = startSample, j = 0; i < totalSamples && j < samplesToCopy; ++i, ++j) {
      leftChannelSamples[i] += leftVol * other.leftChannelSamples[j];
      rightChannelSamples[i] += rightVol * other.rightChannelSamples[j];
    }
  }

  // Clear all samples by setting them to 0
  public void clear() {
    for (int i = 0; i < totalSamples; ++i) {
      leftChannelSamples[i] = rightChannelSamples[i] = 0;
    }
  }

  // Transform the samples to a specified range of amplitude
  private void reMap(float sourceRangeMin, float sourceRangeMax, float destinationRangeMin, float destinationRangeMax) {
    float sourceRange = sourceRangeMax - sourceRangeMin;
    float destinationRange = destinationRangeMax - destinationRangeMin;
    float factor = destinationRange / sourceRange;
    for (int i = 0; i < totalSamples; ++i) {
      leftChannelSamples[i] = destinationRangeMin + (leftChannelSamples[i] - sourceRangeMin) * factor;
      rightChannelSamples[i] = destinationRangeMin + (rightChannelSamples[i] - sourceRangeMin) * factor;
    }
  }

  // The following 4 functions apply post processing to this AudioSamples
  void applyPostProcessing(int postprocess) {
    postprocessEffect(2, postprocess, float(""), float(""));
  }

  void applyPostProcessing(int channel, int postprocess) {
    postprocessEffect(channel, postprocess, float(""), float(""));
  }

  void applyPostProcessing(int channel, int postprocess, float param1) {
    postprocessEffect(channel, postprocess, param1, float(""));
  }

  void applyPostProcessing(int channel, int postprocess, float param1, float param2) {
    postprocessEffect(channel, postprocess, param1, param2);
  }

  // Apply post processing to this AudioSamples, on the specified channel(s)
  // target:
  // - 0 left channel only
  // - 1 right channel only
  // - 2 both channels
  void postprocessEffect(int target, int postprocess, float param1, float param2) {
    // Do nothing if the target is not valid
    if (target < 0 || target > 2) {
      return;
    }

    switch (postprocess) {
      case (1): 
      break; // Nothing is done to the sound
      case (2): 
      applyExponentialDecay(target, param1, param2); 
      break; // Exponential decay
      case (3): 
      applyLowPassFilter(target, param1, param2); 
      break; // Low pass filter
      case (4): 
      applyBandRejectFilter(target, param1, param2); 
      break; // Band reject filter
      case (5): 
      applyFadeIn(target, param1, param2); 
      break; // Linear fade in
      case (6): 
      applyReverse(target, param1, param2); 
      break; // Reverse
      case (7): 
      applyBoost(target, param1, param2); 
      break; // Boost
      case (8): 
      applyTremolo(target, param1, param2); 
      break; // Tremolo
      case (9): 
      applyEcho(target, param1, param2); 
      break; // Echo
      case(10): 
      applyFadeOut(target, param1, param2);
      break; // Linear fade out
    }
  }

  // Apply exponential decay
  private void applyExponentialDecay(int target, float param1, float param2) {

    // Set up the target(s)
    float[] input = new float[0];
    float[] input2 = new float[0];
    switch(target) {
      case(0): 
      input = leftChannelSamples; 
      break;
      case(1): 
      input = rightChannelSamples; 
      break;
      case(2): 
      input = leftChannelSamples; 
      input2 = rightChannelSamples; 
      break;
    }

    float timeConstant = 0.2;  // decay constant, see PDF notes for explanation
    if (!Float.isNaN(param1)) {
      timeConstant = param1;
    }

    for (int i = 0; i < input.length; ++i) {
      float currentTime = float(i) / samplingRate;
      float decayMultiplier = (float) Math.exp(-1 * currentTime / timeConstant);
      input[i] = input[i] * decayMultiplier;

      // Handle the second channel if needed
      if (input2.length > 0) {
        input2[i] = input2[i] * decayMultiplier;
      }
    }
  }

  // Apply low pass filter
  private void applyLowPassFilter(int target, float param1, float param2) {

    // Set up the target(s)
    float[] input = new float[0];
    float[] input2 = new float[0];
    switch(target) {
      case(0): 
      input = leftChannelSamples; 
      break;
      case(1): 
      input = rightChannelSamples; 
      break;
      case(2): 
      input = leftChannelSamples; 
      input2 = rightChannelSamples; 
      break;
    }

    /*** added by bwuai 2016-10-08 ***/
    float[] sampleOut = new float[0];
    sampleOut = input;
    for (int i = 1; i < input.length; i++) {
      sampleOut[i] = 0.5 * sampleOut[i - 1] + 0.5 * sampleOut[i];
      input[i] = sampleOut[i];
    }
    sampleOut = input2;
    for (int i = 1; i < input2.length; i++) {
      sampleOut[i] = 0.5 * sampleOut[i - 1] + 0.5 * sampleOut[i];
      input2[i] = sampleOut[i];
    }
  }

  // Apply band reject filter
  private void applyBandRejectFilter(int target, float param1, float param2) {

    // Set up the target(s)
    float[] input = new float[0];
    float[] input2 = new float[0];
    switch(target) {
      case(0): 
      input = leftChannelSamples; 
      break;
      case(1): 
      input = rightChannelSamples; 
      break;
      case(2): 
      input = leftChannelSamples; 
      input2 = rightChannelSamples; 
      break;
    }

    /*** added by bwuai 2016-10-08 ***/
    float[] sampleOut = new float[0];
    sampleOut = input;
    for (int i = 2; i < input.length; i++) {
      sampleOut[i] = 0.5 * sampleOut[i] + 0.5 * sampleOut[i - 2];
      input[i] = sampleOut[i];
    }
    sampleOut = input2;
    for (int i = 2; i < input2.length; i++) {
      sampleOut[i] = 0.5 * sampleOut[i] + 0.5 * sampleOut[i - 2];
      input2[i] = sampleOut[i];
    }
  }

  // Apply linear fade in
  private void applyFadeIn(int target, float param1, float param2) {

    // Set up the target(s)
    float[] input = new float[0];
    float[] input2 = new float[0];
    switch(target) {
      case(0): 
      input = leftChannelSamples; 
      break;
      case(1): 
      input2 = rightChannelSamples; 
      break;
      case(2): 
      input = leftChannelSamples; 
      input2 = rightChannelSamples; 
      break;
    }

    float fadeValue = 0.5;  // fade in duration, in seconds
    if (!Float.isNaN(param1)) {
      fadeValue = param1;
    }

    /*** added by bwuai 2016-10-08 ***/
    float totFadeSample = fadeValue * samplingRate;

    if ((totFadeSample > input.length) && (input.length > 0)) {
      totFadeSample = input.length;
    }

    if ((totFadeSample > input2.length)&& (input2.length > 0)) {
      totFadeSample = input2.length;
    }

    float fadeMultiplier = 0.0;
    for (int i = 0; i < totFadeSample; i++) {
      fadeMultiplier = i / totFadeSample;
      input[i] = input[i] * fadeMultiplier;
      if(input2.length > 0){
      input2[i] = input2[i] * fadeMultiplier;
      }
    }
  }

  // Apply reverse
  private void applyReverse(int target, float param1, float param2) {

    // Set up the target(s)
    float[] input = new float[0];
    float[] input2 = new float[0];
    switch(target) {
      case(0): 
      input = leftChannelSamples; 
      break;
      case(1): 
      input = rightChannelSamples; 
      break;
      case(2): 
      input = leftChannelSamples; 
      input2 = rightChannelSamples; 
      break;
    }

    /*** added by bwuai 2016-10-08 ***/
    float tmp = 0.0;
    for (int i = 0; i < ((input.length - 1 )/2); i++) {
      tmp = input[i];
      input[i] = input[input.length -1 -i];
      input[input.length -1 -i] = tmp;
    }
    tmp = 0.0;
    for (int i = 0; i < ((input2.length - 1 )/2); i++) {
      tmp = input2[i];
      input2[i] = input2[input2.length -1 -i];
      input2[input.length -1 -i] = tmp;
    }
  }

  // Apply boost
  private void applyBoost(int target, float param1, float param2) {

    // Set up the target(s)
    float[] input = new float[0];
    float[] input2 = new float[0];
    switch(target) {
      case(0): 
      input = leftChannelSamples; 
      break;
      case(1): 
      input = rightChannelSamples; 
      break;
      case(2): 
      input = leftChannelSamples; 
      input2 = rightChannelSamples; 
      break;
    }

    float boostMax = 0; // set a low starting value for the max
    float boostMin = 0;  // set a high starting value for the min

    /*** added by bwuai 206-10-08 ***/
    if (input.length > 0 && input2.length > 0) {
      //doing the stereo boost
      float boostMax1 = boostMax;
      float boostMax2 = boostMax;
      float boostMin1 = boostMin;
      float boostMin2 = boostMin;

      for (int i = 0; i < input.length; i++) {
        if (boostMax1 < input[i]) boostMax1 = input[i];
        if (boostMin1 > input[i]) boostMin1 = input[i];
      }

      for (int i = 0; i < input2.length; i++) {
        if (boostMax2 < input[i]) boostMax2 = input[i];
        if (boostMin2 > input[i]) boostMin2 = input[i];
      }

      boostMin1 = -1 * boostMin1;
      boostMin2 = -1 * boostMin2;
      float biggest1 = max(boostMax1, boostMin1);
      float biggest2 = max(boostMax2, boostMin2);
      float boostMultiplier1 = 0.95 / biggest1;
      float boostMultiplier2 = 0.95 / biggest2;
      float boostMultiplier = min(boostMultiplier1, boostMultiplier2);

      for (int i = 0; i < input.length; i++) {
        input[i] = input[i] * boostMultiplier;
      }

      for (int i = 0; i < input2.length; i++) {
        input2[i] = input2[i] * boostMultiplier;
      }
    } else if (input.length > 0) {
      //doing the mono boost for left channel
      for (int i = 0; i < input.length; i++) {
        if (boostMax < input[i]) boostMax = input[i];
        if (boostMin > input[i]) boostMin = input[i];
      }

      boostMin = -1 * boostMin;
      float biggest = max(boostMax, boostMin);
      float boostMultiplier = 0.95 / biggest;
      for (int i = 0; i < input.length; i++) {
        input[i] = input[i] * boostMultiplier;
      }
    } else if (input2.length > 0) {
      //doing the mono boost for right channel
      for (int i = 0; i < input2.length; i++) {
        if (boostMax < input2[i]) boostMax = input2[i];
        if (boostMin > input2[i]) boostMin = input2[i];
      }

      boostMin = -1 * boostMin;
      float biggest = max(boostMax, boostMin);
      float boostMultiplier = 0.95 / biggest;
      for (int i = 0; i < input2.length; i++) {
        input2[i] = input2[i] * boostMultiplier;
      }
    }
  }

  // Apply tremolo
  private void applyTremolo(int target, float param1, float param2) {

    // Set up the target(s)
    float[] input = new float[0];
    float[] input2 = new float[0];
    switch(target) {
      case(0): 
      input = leftChannelSamples; 
      break;
      case(1): 
      input = rightChannelSamples; 
      break;
      case(2): 
      input = leftChannelSamples; 
      input2 = rightChannelSamples; 
      break;
    }

    float tremoloFrequency = 10; // Frequency of the tremolo effect, change as appropriate
    if (!Float.isNaN(param1)) {
      tremoloFrequency = param1;
    }
    float wetness = 0.5;
    if (!Float.isNaN(param2)) {
      wetness = param2;
    }

    /*** added by bwuai 2016-10-08 ***/
    if (input.length > 0) {
      float tremoloMultiplier = 0.0;
      float current_time = 0.0;
      for (int i = 0; i < input.length; i++) {
        current_time = (float) i / samplingRate;
        tremoloMultiplier = 0.5 * sin(TWO_PI * tremoloFrequency * current_time) +0.5;
        // tremoloMultiplier = (1 - wetness) + (tremoloMultiplier * wetness);
        input[i] = input[i] * tremoloMultiplier;
      }
    }
    if (input2.length > 0 ) {
      float tremoloMultiplier = 0.0;
      float current_time = 0.0;
      for (int i = 0; i < input2.length; i++) {
        current_time = (float) i / samplingRate;
        tremoloMultiplier = 0.5 * sin(TWO_PI * tremoloFrequency * current_time) +0.5;
        //  tremoloMultiplier = (1 - wetness) + (tremoloMultiplier * wetness);
        input2[i] = input2[i] * tremoloMultiplier;
      }
    }
  }

  // Apply echo
  private void applyEcho(int target, float param1, float param2) {
    // You can find pseudo-code for this in the PDF file.
    // You only need to handle one delay line for this project.

    // Set up the target(s)
    float[] input = new float[0];
    float[] input2 = new float[0];
    switch(target) {
      case(0): 
      input = leftChannelSamples; 
      break;
      case(1): 
      input = rightChannelSamples; 
      break;
      case(2): 
      input = leftChannelSamples; 
      input2 = rightChannelSamples; 
      break;
    }

    float delayLineDuration = 0.15; // Length of delay line, in seconds

    if (!Float.isNaN(param1)) {
      delayLineDuration = param1;
    }

    // Need to declare the multiplier for the delay line(s) (just one delay line in this example code)
    float delayLineMultiplier = 0.5;

    if (!Float.isNaN(param2)) {
      delayLineMultiplier = param2;
    }

    /*** added by bwuai 2016-10-08 ***/

    //generate the delay line
    int delayLineLength = (int)Math.floor(delayLineDuration * samplingRate);        
    float[] delayLineSample;
    delayLineSample = new float[delayLineLength];        
    for (int i = 0; i < delayLineLength; i++) {
      delayLineSample[i] = 0.0f;
    }

    //process the delay line
    float delayLineOutput = 0;
    //int clippingCount = 0;
    //doing the echo to left channel
    for (int i = 0; i < (input.length -1); i++) {

      if (i >= delayLineLength) {
        delayLineOutput = delayLineSample[i % delayLineLength];
      } else if (i < delayLineLength) {
        delayLineOutput = 0;
      }

      input[i] = input[i] + (float)(delayLineOutput * delayLineMultiplier);
      /*
      //count bad samples with clipping
      if ((input[i] > 1.0) || input[i] < -1.0) {
        clippingCount++;
      }
      */
      //curremt sample entered into delay line
      delayLineSample[i % delayLineLength] = input[i];
    }       

    //doing the echo to right channel
    delayLineOutput = 0; //initialize again
    for (int i = 0; i < delayLineLength; i++) {  //initialize again
      delayLineSample[i] = 0.0f;
    }

    for (int i = 0; i < (input2.length -1); i++) {

      if (i >= delayLineLength) {
        delayLineOutput = delayLineSample[i % delayLineLength];
      } else if (i < delayLineLength) {
        delayLineOutput = 0;
      }

      input2[i] = input2[i] + (float)(delayLineOutput * delayLineMultiplier);
       /*
      //count bad samples with clipping
      if ((input2[i] > 1.0) || input2[i] < -1.0) {
        clippingCount++;
      }
      */
      //curremt sample entered into delay line
      delayLineSample[i % delayLineLength] = input2[i];
    }       
    
  }
  
  // Apply linear fade in
  private void applyFadeOut(int target, float param1, float param2) {

    // Set up the target(s)
    float[] input = new float[0];
    float[] input2 = new float[0];
    switch(target) {
      case(0): 
      input = leftChannelSamples; 
      break;
      case(1): 
      input2 = rightChannelSamples; 
      break;
      case(2): 
      input = leftChannelSamples; 
      input2 = rightChannelSamples; 
      break;
    }

    float fadeValue = 0.5;  // fade out duration, in seconds
    if (!Float.isNaN(param1)) {
      fadeValue = param1;
    }

    /*** added by bwuai 2016-10-22 ***/
    float totFadeSample = fadeValue * samplingRate;

    if ((totFadeSample > input.length) && (input.length > 0)) {
      totFadeSample = input.length;
    }

    if ((totFadeSample > input2.length)&& (input2.length > 0)) {
      totFadeSample = input2.length;
    }

    int start = int(input.length - totFadeSample);
    float fadeMultiplier = 0.0;
    float tmp = 0.0;
    for (int i = start; i < totFadeSample; i++) {
      tmp = i - start;
      fadeMultiplier = 1 - (tmp / totFadeSample);
      input[i] = input[i] * fadeMultiplier;
      if(input2.length > 0){
      input2[i] = input2[i] * fadeMultiplier;
      }
    }
  }
  
}