# HLS ug871 tutorial

Change Vivado HLS to Vitis HLS

### command

vitis_hls -f run_hls.tcl

vitis_hls -p prj

1. p33
    
    ![Untitled](imgs/Untitled.png)
    
2. p36 analyze
    
    没找到analysis button在哪里
    
    ![Untitled](imgs/Untitled%201.png)
    
3. P42 Compare Report
    
    看上去vitis确实比viviado hls优化了
    
    ![Untitled](imgs/Untitled%202.png)
    
    ![Untitled](imgs/Untitled%203.png)
    
4. Interface Synthesis实验
    
    实验内容：一个三输入的加法器
    
    ![Untitled](imgs/Untitled%204.png)
    
    |  | solution1 | solution2 | solution3 | solution4 | lab4 |
    | --- | --- | --- | --- | --- | --- |
    | 算法 | 直接相加 | 输出用pointer | for循环相加，输入输出都是array | for循环，输入输出都是array | array → AXI Interface |
    | HLS优化策略 | 输入是ap_none接口 | 输出综合成为一个inout接口
    in1：ap_vld
    in2: ap_ack
    inout: ap_hs | -HLS默认array综合成RAM Ports
    -将输入输出部分展开（directive设置成block） | -UNROLL全部展开输入输出（directive设置成complete） | - partition the arrays
    -Unroll loop
    -pipeline loop |
    
    ![Untitled](imgs/Untitled%205.png)
    
    可以看出来solution4占用的资源不是最多的，延时是最小的
    
    lab4延时略增加，面积更小了
    
5. P109 Design Analysis 如何降低latency
    
    solution1:
    
    ![Untitled](imgs/Untitled%206.png)
    
    pipeline后(solution2)：
    
    ![Untitled](imgs/Untitled%207.png)
    
    为什么solution2 latency还变大了？？？
    
    solution3:
    
    ![Untitled](imgs/Untitled%208.png)
    
    solution4:
    
    ![Untitled](imgs/Untitled%209.png)
    
    solution5:
    
    ![Untitled](imgs/Untitled%2010.png)
    
    solution6:
    
    ![Untitled](imgs/Untitled%2011.png)
    
    Compare:
    
    ![Untitled](imgs/Untitled%2012.png)
    
6. P137 Design Optimization (3*3矩阵相乘）
    
    有violation？
    
    ![Untitled](imgs/Untitled%2013.png)
    
    pipeline后没有violation
    
    ![Untitled](imgs/Untitled%2014.png)
    
    solution3又有violation
    
    ![Untitled](imgs/Untitled%2015.png)
    
    solution4：
    
    ![Untitled](imgs/Untitled%2016.png)
    
    solution5：
    
    ![Untitled](imgs/Untitled%2017.png)
    
    solution6也有violation
    
    ![Untitled](imgs/Untitled%2018.png)
    
7. RTL Verification
    
    Lab1：无法跑C synthesis
    
    ![Untitled](imgs/Untitled%2019.png)
    
    lab2：
    
    ![Untitled](imgs/Untitled%2020.png)
    
    lab3：
    
    ![Untitled](imgs/Untitled%2021.png)
    
    error：
    
    ![Untitled](imgs/Untitled%2022.png)
    
8. Using HLS IP in IP Integrator
    
    vitis生成的HLS IP接口、vivado生成的HDL Wrapper接口名字和tutorial的testbench名字不匹配，需要自己修改
    
9. 最后一个实验：Package HLS IP for System Generator
    
    根据xsetup，System Generator已经被整合到Vitis Model Composer里面了
    
    ![Untitled](imgs/Untitled%2023.png)
    
    *需要下载matlab