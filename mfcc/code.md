# DTW

私有的几个数据类型：

```cpp
private:
    vector<float> xishu;
    double *Hamming;
    vector<vector<float> > SourceMFCCs;
    int MFCC_P;
    int MFCC_Pf;
    int FrmLen;
    int FFTLen;
```

重点在函数

```cpp
Private:
float ComputeDTW(float *cep1, float *cep2, int num1, int num2);
    float Distance(float * ps1,float * ps2,int k1,int k2);

    void AdjustSize();
```

```cpp
Public:
float ComputeDTW(vector<vector<float> > cep1,vector<vector<float> > cep2);
    WaveFunction(int frm_len, int mfcc_num); //构造函数，带参数的构造函数在创建类的时候赋初值
		~WaveFunction(); //析构函数
```

Function_Defs

构造函数：

```cpp
DTW_Function::DTW_Function(int frm_len, int mfcc_num){ //frm_len:每帧的采样点数，mfcc_num: mfcc的维数
    MFCC_P=mfcc_num;
    MFCC_Pf=float(mfcc_num);
    FrmLen=frm_len;
    FFTLen=frm_len;
    Hamming=new double[FrmLen];
}
```

析构函数：

```cpp
DTW_Function::~DTW_Function(){
    delete []Hamming; //释放内存
}
```

提取MFCC参数

```cpp
vector<vector<float> > DTW_Function::getMFCCs(string filename){
//使用类模板vector, vector可以改变长度
    xishu.clear(); //系数是vector<float>, 有函数clear
    SourceMFCCs.clear(); //是二维向量
    //mfcc分析
    mTWavHeader waveheader; //结构体mTWavHeader
    FILE *sourcefile;
    short buffer[FrmLen];
    float data[FrmLen];
    float FiltCoe1[FFTLen/2+1];  //左系数
    float FiltCoe2[FFTLen/2+1];  //右系数
    int Num[FFTLen/2+1];     //决定每个点属于哪一个滤波器
    float En[FiltNum+1];         //频带能量
    vector<complex<float> > vecList;

    sourcefile=fopen(filename.c_str(),"rb");
    fread(&waveheader,sizeof(mTWavHeader),1,sourcefile);
    InitHamming();//初始化汉明窗
    InitFilt(FiltCoe1,FiltCoe2,Num); //初始化MEL滤波系数

    while(fread(buffer,sizeof(short),FrmLen,sourcefile)==FrmLen){
        HammingWindow(buffer,data); //加窗
        ComputeFFT(data,vecList); //计算FFT
        Filt(data, FiltCoe1, FiltCoe2, Num, En,vecList); //滤波
        MFCC(En);  //求滤波器能量
        vecList.clear();
        fseek(sourcefile, -FrmLen/2, SEEK_CUR);//考虑到帧移，每次移动半帧
    }

    int stdlength=xishu.size();

    for(int i=0;i<stdlength/MFCC_P;i++){
        vector<float> temp;
        for(int j=0;j<MFCC_P;j++)
            temp.push_back(xishu[i*MFCC_P+j]); 
        SourceMFCCs.push_back(temp); //push_back在末尾添加元素
    }
    fclose(sourcefile);
    return SourceMFCCs;
}
```

//MFCC 提取出的是vector

```cpp
void DTW_Function::MFCC(float *En) //En是能量
{
    int idcep, iden;
    float Cep[MFCC_P];

    for(idcep = 0 ; idcep < MFCC_P ; idcep++)
    {
        Cep[idcep] = 0.0;

        for(iden = 1 ; iden <= FiltNum ; iden++)
        {
            Cep[idcep] = Cep[idcep] + En[iden] * (float)cos((idcep+1) * (iden-0.5F) * PI/(FiltNum));
        }
        Cep[idcep] = Cep[idcep] / 10.0F;
        xishu.push_back(Cep[idcep]);
    }
}
```

对MFCC系数做一阶差分

```cpp
vector<vector<float> > DTW_Function::addFirstOrderDifference(vector<vector<float> > mfccs){
    vector<vector<float> > temp;
    for(int i=0;i<mfccs.size();i++){ //MFCC向量的个数
        vector<float> line=mfccs[i];
        int size=line.size(); //MFCC特征的维数(未差分前是13维)
        for(int t=0;t<size;t++){
            if(t<2)
                line.push_back(line[t+1]-line[t]); //t0和t1, 前两项只求差
            else{
                if(t>size-2||t==size-2)  //
                    line.push_back(line[t]-line[t-1]);
                else{
                    float fenzi=line[t+1]-line[t-1]+2*(line[t+2]-line[t-2]);
                    float fenmu=sqrtf(10);
                    line.push_back(fenzi/fenmu); //push_back, 追加写到后面，追加写到26维

                }
            }
        }
        temp.push_back(line); //line现在是13+13维向量
    }
    return temp;
}
```

MFCC做二阶差分：

```cpp
vector<vector<float> > DTW_Function::addOrderDifference(vector<vector<float> > mfccs){
    vector<vector<float> > temp;
    for(int i=0;i<mfccs.size();i++){
        vector<float> line=mfccs[i];
        int size=line.size();
        //一阶差分
        for(int t=0;t<size;t++){
            if(t<2)
                line.push_back(line[t+1]-line[t]);
            else{
                if(t>size-2||t==size-2)
                    line.push_back(line[t]-line[t-1]);
                else{
                    float fenzi=line[t+1]-line[t-1]+2*(line[t+2]-line[t-2]);
                    float fenmu=sqrtf(10);
                    line.push_back(fenzi/fenmu);

                }
            }
        }
        //二阶差分
        for(int t=size;t<size*2;t++){  //在一阶差分的基础上再push_back一次
            if(t<2)
                line.push_back(line[t+1]-line[t]);
            else{
                if(t>size-2||t==size-2)
                    line.push_back(line[t]-line[t-1]);
                else{
                    float fenzi=line[t+1]-line[t-1]+2*(line[t+2]-line[t-2]);
                    float fenmu=sqrtf(10);
                    line.push_back(fenzi/fenmu);

                }
            }
        }
        temp.push_back(line); //line现在是13+13+13维向量
    }
    return temp;
}
```

**Dynamic Time Warping**

```cpp
**//此函数是类的公有函数**
float DTW_Function::ComputeDTW(vector<vector<float> > cep1, vector<vector<float> > cep2)
{
    vector<float> temp;
    for(int i=0;i<cep1.size();i++)
        for(int j=0;j<cep1[i].size();j++)
            temp.push_back(cep1[i][j]);  //MFCC的二维数组转一维
    int stdlength=temp.size();  //总共的点数
    float * stdmfcc = new float[stdlength];  //分配存储空间
    std::copy(temp.begin(),temp.end(),stdmfcc);  //begin返回指向开头的指针, end返回指向结尾的指针
    //把temp拷到stdmfcc里

    vector<float> temp1;
    for(int i=0;i<cep2.size();i++)
        for(int j=0;j<cep2[i].size();j++)
            temp1.push_back(cep2[i][j]);
    int testlen=temp1.size();
    float * testmfcc = new float[testlen];
    std::copy(temp1.begin(),temp1.end(),testmfcc);
    return ComputeDTW(stdmfcc,testmfcc,stdlength/MFCC_P,testlen/MFCC_P);
}
```

```cpp
**//此函数是类的私有函数**
float DTW_Function::ComputeDTW(float *cep1, float *cep2, int num1, int num2){
    struct record
    {		int x;
                int y;
    };
    struct point
    {		int x,y;
                float minvalue;
                        int stepnum;
                                bool recheck;               //记录该点是否被记录过
    };
    record * re;
    record * newre;

    newre=new record[num1*num2];    //记录下一层的所有点
    re=new record[num1*num2];       //记录当层的所有点
    int renum;
    int newrenum=0;
    int i,j;
    point * poi;
    poi=new point[num1*num2];

    for(i=0;i<num1*num2;i++)
    {
        poi[i].recheck=0;
        poi[i].minvalue=INF;
        poi[i].stepnum=0;
    }								//设置初始值

    for(i=0;i<5;i++)                //起始点
    {
        if(i==0)  {	re[i].x=1; re[i].y=1; }
        if(i==1)  {	re[i].x=1; re[i].y=2; }
        if(i==2)  {	re[i].x=1; re[i].y=3; }
        if(i==3)  {	re[i].x=2; re[i].y=1; }
        if(i==4)  {	re[i].x=3; re[i].y=1; }
        poi[(re[i].y-1)*num1+re[i].x-1].minvalue=Distance(cep1,cep2,re[i].x,re[i].y);
        poi[(re[i].y-1)*num1+re[i].x-1].stepnum=1;
    }
    renum=5;
    int newx,newy;                   //newvalue;
    for(i=0;i<renum;i++)
    {
        for(j=0;j<3;j++)
        {
            if(j==0){ newx=re[i].x+1; newy=re[i].y+2; }
            if(j==1){ newx=re[i].x+1; newy=re[i].y+1; }
            if(j==2){ newx=re[i].x+2; newy=re[i].y+1; }

            /////////////三种可能路径

            if(newx>=num1||newy>=num2)
                continue;
            if(fabs(newx-newy)<=fabs(num1-num2)+3)
            {
                if(poi[(newy-1)*num1+newx-1].recheck==0)
                {
                    newre[newrenum].x=newx;
                    newre[newrenum].y=newy;
                    newrenum++;
                }
                float tmpdis;
                int addstepnum;
                if(j==0){ tmpdis=Distance(cep1,cep2,newx-1,newy-1)*2+Distance(cep1,cep2,newx,newy); addstepnum=2;}
                if(j==1){ tmpdis=Distance(cep1,cep2,newx,newy)*2; addstepnum=1;}
                if(j==2){ tmpdis=Distance(cep1,cep2,newx-1,newy-1)*2+Distance(cep1,cep2,newx,newy); addstepnum=2;}
                if(poi[(newy-1)*num1+newx-1].minvalue>(poi[(re[i].y-1)*num1+re[i].x-1].minvalue+tmpdis))
                {
                    poi[(newy-1)*num1+newx-1].minvalue=(poi[(re[i].y-1)*num1+re[i].x-1].minvalue+tmpdis);
                    poi[(newy-1)*num1+newx-1].stepnum=poi[(re[i].y-1)*num1+re[i].x-1].stepnum+addstepnum;
                }
                if(poi[(newy-1)*num1+newx-1].recheck==0)
                    poi[(newy-1)*num1+newx-1].recheck=1;
            }
        }
        if(newrenum!=0 && i>=(renum-1))
        {
            renum=newrenum;
            newrenum=0;
            struct	record * tt;
            tt=re;
            re=newre;
            newre=tt;
            i=-1;
        }
    }
    float min=INF;
    for(j=0;j<renum;j++)
    {
        if((poi[(re[j].y-1)*num1+re[j].x-1].minvalue)/poi[(re[j].y-1)*num1+re[j].x-1].stepnum<min)
            min=(poi[(re[j].y-1)*num1+re[j].x-1].minvalue)/poi[(re[j].y-1)*num1+re[j].x-1].stepnum;
    }

    //	min;
    delete []poi;
    delete []newre;
    delete []re;
    delete []cep1;
    delete []cep2;
    return min;
}
```

计算距离

```cpp
float DTW_Function::Distance(float *ps1, float *ps2, int k1, int k2){
    int i=0;
    float sum=0;
    for(i=0;i<MFCC_P;i++)
        sum+=(1+MFCC_Pf/2*(float)sin(PI*i/MFCC_Pf))*(ps1[k1+i]-ps2[k2+i])*(ps1[k1+i]-ps2[k2+i]);

    return sum;
}
```