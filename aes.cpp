#include "aes.h"

AES::AES(){
  
this->plen=0;
this->num_of_rounds=10;
this->total_bytes=176;
this->padded_message=NULL;
 
}

AES::~AES(){

}
 
void AES::Encrypt(unsigned  char*message, unsigned char* key){
    
    paddedMessage(message);
    for(int i=0;i<plen;i+=16){
        encrypt(padded_message+i,key);
    }
}
 //AES Encrypt
  void AES:: encrypt(unsigned char* message,unsigned  char* key){

     unsigned  char state[16];
      for(int i=0;i<16;i++){
          state[i]=message[i];
      }
     unsigned  char expendedKey[176];
      expendKey(key,expendedKey);
      addRoundKey(state,key);
      for(int i=1;i<num_of_rounds-1;i++){
          subyte(state);
         shiftRow(state);
         mixColumn(state);
         addRoundKey(state,expendedKey + (16*i));
      }
      //Last Round
      subyte(state);
      shiftRow(state);
      addRoundKey(state,expendedKey + 160);
      for(int i=0;i<16;i++){
        message[i]=  state[i];
      }

  }




  void AES::expendKey(unsigned char* key,unsigned char *expendedKey){
          for(int i=0;i<16;i++){
              expendedKey[i]=key[i];
          }
          int generatedBytes=16;
          int rConst=1;
          char temp[4];

          while(generatedBytes< TOTAL_BYTES){
             
               for(int j=0;j<4;j++){
                   temp[j]=expendedKey[j+generatedBytes-4];
               }
               if(generatedBytes%16==0){
                    //Rotate row left
                   char t=temp[0];
                   temp[0]=temp[1];
                   temp[1]=temp[2];
                   temp[2]=temp[3];
                   temp[3]=t;
                   //sub bytes
                   temp[0]=sbox[temp[0]];
                   temp[1]=sbox[temp[1]];
                   temp[2]=sbox[temp[2]];
                   temp[3]=sbox[temp[3]];
                 
                   //rotation constant
                   temp[0]=temp[0]^rcon[rConst++];

               }

               for(int i=0;i<4;i++){
                   expendedKey[generatedBytes]=expendedKey[generatedBytes-16]^temp[i];
                   generatedBytes++;
               }


          }

  }
  void AES::subyte(unsigned char * state){
      for(int i=0;i<16;i++){
          state[i]=sbox[state[i]];
      }
  }
  void AES::shiftRow(unsigned char * state){
      char temp[16];

     temp[0]=state[0];
     temp[1]=state[5];
     temp[2]=state[10];
     temp[3]=state[15];

     temp[4]=state[4];
     temp[5]=state[9];
     temp[6]=state[14];
     temp[7]=state[3];

     temp[8]=state[8];
     temp[9]=state[13];
     temp[10]=state[2];
     temp[11]=state[7];

     temp[12]=state[12];
     temp[13]=state[1];
     temp[14]=state[6];
     temp[15]=state[11];
     for(int i=0;i<16;i++){
         state[i]=temp[i];
     }

  }
  void AES::mixColumn(unsigned char * state){
    char tmp[16];
    tmp[0] = (unsigned char)(mul2[state[0]] ^ mul3[state[1]] ^ state[2] ^ state[3]);
    tmp[1] = (unsigned char)(state[0] ^ mul2[state[1]] ^ mul3[state[2]] ^ state[3]);
    tmp[2] = (unsigned char)(state[0] ^ state[1] ^ mul2[state[2]] ^ mul3[state[3]]);
    tmp[3] = (unsigned char)(mul3[state[0]] ^ state[1] ^ state[2] ^ mul2[state[3]]);

    tmp[4] = (unsigned char)(mul2[state[4]] ^ mul3[state[5]] ^ state[6] ^ state[7]);
    tmp[5] = (unsigned char)(state[4] ^ mul2[state[5]] ^ mul3[state[6]] ^ state[7]);
    tmp[6] = (unsigned char)(state[4] ^ state[5] ^ mul2[state[6]] ^ mul3[state[7]]);
    tmp[7] = (unsigned char)(mul3[state[4]] ^ state[5] ^ state[6] ^ mul2[state[7]]);

    tmp[8] = (unsigned char)(mul2[state[8]] ^ mul3[state[9]] ^ state[10] ^ state[11]);
    tmp[9] = (unsigned char)(state[8] ^ mul2[state[9]] ^ mul3[state[10]] ^ state[11]);
    tmp[10] = (unsigned char)(state[8] ^ state[9] ^ mul2[state[10]] ^ mul3[state[11]]);
    tmp[11] = (unsigned char)(mul3[state[8]] ^ state[9] ^ state[10] ^ mul2[state[11]]);

    tmp[12] = (unsigned char)(mul2[state[12]] ^ mul3[state[13]] ^ state[14] ^ state[15]);
    tmp[13] = (unsigned char)(state[12] ^ mul2[state[13]] ^ mul3[state[14]] ^ state[15]);
    tmp[14] = (unsigned char)(state[12] ^ state[13] ^ mul2[state[14]] ^ mul3[state[15]]);
    tmp[15] = (unsigned char)(mul3[state[12]] ^ state[13] ^ state[14] ^ mul2[state[15]]);

    for(int i=0;i<16;i++){
        state[i]=tmp[i];
    }


  }
  void AES::addRoundKey(unsigned char * state,unsigned char* expendedKey){
      for(int i=0; i<16;i++){
          state[i]=state[i]^expendedKey[i];
      }

  }
   void AES:: paddedMessage(unsigned char* message){
       int mlen=strlen((const char*)message);
        plen=mlen;
       if(plen%16!=0){
           plen=(plen/16 +1)*16;
       }
       padded_message=new unsigned char[plen];
       for(int i=0;i<plen;i++){
           if(i>=mlen) {
               padded_message[i]=0;
           }else{
                 padded_message[i]=message[i];

           }
       }
   }
   void AES::printHEx(char x){
    if(x/16 <10) cout<<(char)((x/16)+ '0');
    if(x/16 >=10) cout<<(char)((x/16 -10)+ 'A');

    if(x%16 <10) cout<<(char)((x%16)+ '0');
    if(x%16 >=10) cout<<(char)((x%16 -10)+ 'A');
   }
   void AES::printPM(){
       for(int i=0;i<plen;i++){
           printHEx( padded_message[i]);
           cout<<" ";
       }

   }

 //AES Decrypt
 void AES::Dencrypt(unsigned char* message,unsigned char* key){
       
 }