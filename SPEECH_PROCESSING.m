%SPEECH PROCESSING !!
textIn = 'ah';
ha = actxserver('SAPI.SpVoice');
invoke(ha,'speak',textIn);