# Result

python上的运行结果：（测试100次）

![Untitled](imgs/Untitled.png)

VS code的运行结果：（编译器MinGW）

![Untitled](imgs/Untitled%201.png)

![Untitled](imgs/Untitled%202.png)

Visual Studio的运行结果：(不要用Debug模式，用Release）

1、正确率

![Untitled](imgs/Untitled%203.png)

2、调试模式看资源使用率

![Untitled](imgs/Untitled%204.png)

计算DTW的函数占用了较多资源

![Untitled](imgs/Untitled%205.png)

其中计算距离的函数占用了大量的CPU资源

![Untitled](imgs/Untitled%206.png)

![Untitled](imgs/Untitled%207.png)

内存：

![Untitled](imgs/Untitled%208.png)

![Untitled](imgs/Untitled%209.png)

重复匹配10次，所以内存总共下降9次（最后一次全部释放）

![Untitled](imgs/Untitled%2010.png)

Zedboard运行结果：

![Untitled](imgs/Untitled%2011.png)

vector类的内存不够

### 需要分配堆栈内存

![Untitled](imgs/Untitled%2012.png)

![Untitled](imgs/Untitled%2013.png)