#include <stdio.h>
#include <stdlib.h>
#include <CSValue.h>
//start global
HDF hdf;
//function start with __$ is compile generated
//Begin Each Wrappers
void __$eachWrapper(){
  int i = 0;
  CSValue* myselect;
  CSValueArray* __$arr = CSGetHdfChildren(hdf,"Query.myselect");
  for(i=0;i<CSValueArray.length;i++){
    CSValue* __$if =CSAllocValue();
    CSValue* __$a =  CSGetHdfValue(hdf,"first");
    CSValue* __$static_0 = CSValueNumber(0)£»
    CSConvertToNumberic(__$if,__$a);
    myselect = *(CSValueArray->array+i);
    if(CSIf(__$if)){
      CSSetHdfValue("first",__$static_0);
    }else{
      CSEcho(",");
    }
    CSVar("myselect");
  }
}
//End Each Wrappers
int main(){
  hdf = InitHDF();
  CSValue *A = CSAllocValue();
  CSValue *B = CSGetHdfValue(hdf,"Query.myselect.0");
  CSValue *C = CSValueNumber(1);
  if(CSIf(A)){
    CSEcho("myselect=");
    CSSetHdfValue(hdf,"first",C);
    __$eachWrapper();
  }else{
    CSEcho("myselect=");
    CSVar("Query.myselect");
    //pass
  }
    
}
