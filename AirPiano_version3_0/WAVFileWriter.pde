//write the sound to WAV file
class WAVFileWriter {

    String filename;

    int chunkSize;    // = numOfSample + dataSize + fmrChunkSize + dataChunkSize

    int fmtChunkSize;     // 16 for PCM
    short audioFormat;    // 1 for PCM
    short channel;    // mono = 1, stereo = 2
    int samplingRate;     // could be 8000, 44100, ...
    int  bytePerSec;    // = samplingRate * channel * bitPerSample / 8
    short blockAlign;     // = channel * bitPerSample / 8
    short bitPerSample;   // 8, 16, etc

    int dataSize;     // number of bytes in the data


    // constructor
    WAVFileWriter(String _filename) {
        filename = _filename;
    }

    // save to WAV file in Stereo format
    void Save(float[] dataLeft, float[] dataRight, int _samplingRate) {
        // Check if the length of dataLeft and dataRight are the same
        if(dataLeft.length != dataRight.length) {
            println(">>>  Data length of the two channel does not match! Left:" + dataLeft.length + " Right:" + dataRight.length);
        }

        samplingRate = _samplingRate;
        channel = 2;
        bitPerSample = 16;
        audioFormat = 1;
        fmtChunkSize = 16;
        blockAlign = (short)(channel * bitPerSample / 8.0);
        bytePerSec = int(samplingRate * channel * bitPerSample / 8.0);
        dataSize = dataLeft.length * blockAlign;
        chunkSize = dataSize + 8 + 12 + fmtChunkSize;

        try {
            DataOutputStream dataoutputstream = new DataOutputStream(new FileOutputStream(filename));

            // write "RIFF" chunk
            dataoutputstream.writeBytes("RIFF");    // chunk ID
            dataoutputstream.writeInt(swapInt(chunkSize));
            dataoutputstream.writeBytes("WAVE");    // format

            // write "format" chunk
            dataoutputstream.writeBytes("fmt ");    // "fmt" chunk ID
            dataoutputstream.writeInt(swapInt(fmtChunkSize));
            dataoutputstream.writeShort(swapShort(audioFormat));
            dataoutputstream.writeShort(swapShort(channel));
            dataoutputstream.writeInt(swapInt(samplingRate));
            dataoutputstream.writeInt(swapInt(bytePerSec));
            dataoutputstream.writeShort(swapShort(blockAlign));
            dataoutputstream.writeShort(swapShort(bitPerSample));

            // write "data" chunk
            dataoutputstream.writeBytes("data");        // "data" chunk ID
            dataoutputstream.writeInt(swapInt(dataSize));

            // write actual sound data (for 16-bit stereo)
            // need to convert the data from float to short
            short sdata = 0;
            byte[] outputBuffer = new byte[dataSize*2];
            for(int i = 0; i < dataLeft.length; ++i) {

                // Left channel
                if (dataLeft[i] >= 0) {
                    sdata = (short)(dataLeft[i] * 32767);
                } else if (dataLeft[i] < 0) {
                    sdata = (short)(dataLeft[i] * 32768);
                }

                outputBuffer[i*4] = (byte)(sdata & 0xff);
                outputBuffer[i*4+1] = (byte)((sdata >> 8) & 0xff);
            }

            for(int i = 0; i < dataRight.length; ++i) {

                // Right channel
                if (dataRight[i] >= 0) {
                    sdata = (short)(dataRight[i] * 32767);
                } else if (dataRight[i] < 0) {
                    sdata = (short)(dataRight[i] * 32768);
                }

                outputBuffer[i*4+2] = (byte)(sdata & 0xff);
                outputBuffer[i*4+3] = (byte)((sdata >> 8) & 0xff);
            }

            dataoutputstream.write(outputBuffer, 0, outputBuffer.length);

            dataoutputstream.close();
        } catch(IOException ioexception) {
            ioexception.printStackTrace();
        }
    }

    // swap the bytes in the Integer (4 bytes)
    int swapInt(int i) {
        int byte0 = i & 0xff;
        int byte1 = (i >> 8) & 0xff;
        int byte2 = (i >> 16) & 0xff;
        int byte3 = (i >> 24) & 0xff;
        // swap the byte order
        return (byte0 << 24) | (byte1 << 16) | (byte2 << 8) | byte3;
    }

    // swap the bytes in the Short  (2 bytes)
    short swapShort(short i) {
        int byte0 = i & 0xff;
        int byte1 = (i >> 8) & 0xff;

        // swap the byte order
        return (short)((byte0 << 8) | byte1);
    }
}

}