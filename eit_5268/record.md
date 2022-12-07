# 记录

Google Colab

![Untitled](imgs/Untitled.png)

### train_promote.ipynb

训练10个epoch

1、96，64，1

2、增大第一层神经元的个数：96→256

3、增加一个全连接层，96

4、增加dropout

### 使用keras tuner确定超参数

![Untitled](imgs/Untitled%201.png)

不加uniform的模型

![Untitled](imgs/Untitled%202.png)

![Untitled](imgs/Untitled%203.png)

加了uniform

![Untitled](imgs/Untitled%204.png)

![Untitled](imgs/Untitled%205.png)

激活函数换成relu

![Untitled](imgs/Untitled%206.png)

更新：

![train.png](imgs/train.png)

激活函数Relu → 对应初始化适合用henormal而不是uniform

模型：

![Untitled](imgs/Untitled%207.png)

尝试将模型加到5层

![Untitled](imgs/Untitled%208.png)

还是使用3层的模型，损失函数换成mean abs error

![mae.png](imgs/mae.png)

![mse.png](imgs/mse.png)