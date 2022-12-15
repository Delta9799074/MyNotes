# lab5

General:STOTO是一个有两百多行的模块

![Untitled](imgs/Untitled.png)

![Untitled](imgs/Untitled%201.png)

![Untitled](imgs/Untitled%202.png)

![Untitled](imgs/Untitled%203.png)

my tcl

> set_svf STOTO.svf
read_file -format verilog {/home/asic_22215597/dc_lab/DC1_2012.06_part1/DC1_2012.06/lab5/rtl/STOTO.v}
current_design STOTO
link
source STOTO.con
*#查看设计的时序是否收敛，即设计能否满足时序的要求，这里还没综合所以应该是check*
report_timing
source STOTO.pcon
*#报告当前设计中的路径分组情况*
report_path_group
> 
> 
> report_port -verbose
> 
> set_ungroup INPUT false
> 
> set_optimize_registers true -design PIPELINE -clock clk -delay_threshold 2.1
> 
> set_dont_retime [get_cells PIPELINE/POUT] true
> 
> report_constraint -all_violators
> 

reference tcl

> set_svf STOTO.svf
read_verilog STOTO.v
> 
> 
> current_design STOTO
> 
> link
> check_design
> 
> source STOTO.con
> *#检查时序约束是否完整，综合前check，综合后report*
> check_timing
> 
> source STOTO.pcon
> *#自定义路径组且 clk 路径组的权重为最高(5)*
> 
> group_path -name clk -critical 0.21 -weight 5
> group_path -name INPUTS -from [all_inputs]
> group_path -name OUTPUTS -to [all_output]
> group_path -name COMBO -from [all_inputs] -to [all_output]
> 
> *###############################################*
> 
> set_ungroup [get_designs "INPUT"] false
> 
> set_dont_retime [get_cells I_MIDDLE/I_DONT_PIPELINE] true
> 
> set_optimize_registers true -design PIPELINE
> 
> set_dont_retime [get_cells I_MIDDLE/I_PIPELINE/z_reg*] true
> 
> write -f ddc -hier -out unmapped/STOTO.ddc
> 
> set_host_options -max_cores 4
> 
> compile_ultra  -scan  -timing -retime
> 
> report_hierarchy -noleaf
> 
> redirect -tee -file rc_compile_ultra.rpt {report_constraint -all}
> redirect -tee -file rt_compile_ultra.rpt {report_timing}
> 
> write -f ddc -hier -out mapped/STOTO.ddc
> 
> set_svf -off
> 
> get_cells -hier r_REG*_S*
> 
> report_cell -nosplit I_MIDDLE/I_PIPELINE
> #验证z_reg是否被移动，出现值证明没被移动
> 
> get_cells -hier *z_reg*
> 
> report_timing -from I_MIDDLE/I_PIPELINE/z_reg*/*
> 
> get_cells -hier R_*
> 
> report_cell -nosplit I_IN
> 
> get_cells  I_IN/*_reg*
> 
> exit
> 

## 自定义路径组（**(divide-and-conquer的策略）**

- 命令
    
    ***group_path -name INPUTS  -from [all_inputs]***
    
    ***group_path -name OUTPUTS -to [all_outputs]***
    
    ***group_path -name COMBO -from [all_inputs] -to [all_outputs]***
    
- 上面的命令产生**三个自定义**的路径组，加上原有的路径组，即寄存器到寄存器的路径组（因为**受CLK**控制，默认的是CLK的路径组），现在有4个路径组。组合电路的路径，属于“**COMBO**”组，由于该**路径组的起点是输入端**，在执行“**group_path -name INPUTS -from [all_inputs]**”命令后,命令中用了选项“**-from  [all_inputs]**"，它们原先属于“**INPUTS**”组。在执行“**group_path -name OUTPUTS -to [all_outputs]**”命令后，组合电路的路径**不会被移到**“**OUTPUTS**”组，因为**开关选项‘'-from”的优先级高于选项”-to”**，因此组合电路的路径还是留在“INPUTS”路径组。但是由于“**group_path -name COMBO -from [all_inputs] -to [all-outputs]**”命令中**同时**使用了开关选项“-from”和“-to" ,组合电路路径的起点和终点同时满足要求，因此它们最终归属于“**COMBO**”组。DC以这种方式工作来防止由于命令次序的改变而使结果不同。我们可以**report_path_group**命令来得到设计中**时序路径组**的情况。
- 指定权重进行优化，当某些路径时序较差时，可以通过指定权重，着重优化该路径
    
    *group_path -name clk -critical 0.21 -weight 5*
    

## Problem

1. source STOTO.pcon出错
    
    ![Untitled](imgs/Untitled%204.png)
    
    要在dc_shell -topo模式下打开
    
2. report_path_group只有一组，怎么生成的四组？
    
    自定义生成的
    
    ![Untitled](imgs/Untitled%205.png)
    

## Design Specification

| specification | my constraint | reference | 说明 |
| --- | --- | --- | --- |
| the I/O constraints are estimates and have been conservatively constrained | report_port -verbose |  |  |
| The final compiled design should meet setup timing on all internal register-to-register paths | ？ | set_cost_priority -delay |  |
| The **INPUT** block hierarchy should be preserved to facilitate post-synthesis verification | set_ungroup INPUT false | set_ungroup [get_designs “INPUT”] false | 防止特定的子模块被 ungrouped:
set_ungroup  <top_level_and/or_pipeiined_blocks>  false |
| The **PIPELINE** block contains a "pure" pipelined design | set_optimize_registers true -design PIPELINE -clock clk -delay_threshold 2.1 | set_optimize_registers true -design PIPELINE | 如果设计中包含有纯的流水线设计，那么可以进行寄存器retiming:
　　　　set_optimize_registers  true  -design  My_Pipeline_Subdesign -clock CLK1 -delay_threshold <clock_period> |
| The output (**POUT**) of **PIPELINE** must remain registered | set_dont_retime [get_cells PIPELINE/POUT] true | set_dont_retime [get_cells I_MIDDLE/I_PIPELINE/z_reg*] true | 如果有要求保持流水线中的寄存器器输出，就要进行约束：
set_dont_retime [get_cells  U_Pipeline/R12_reg*]  true |
| The positions of non-pipelined registers in the **I_DONT__PIPELINE** block are fixed and cannot be modified | ？ | set_dont_retime [get_cells I_MIDDLE/I_DONT_PIPELINE] true | 从适应性重新定时中排除特定的单元/设计(-retime)(也就是放在某些模块或者设计的寄存器被retime移动): set_dont_retime  <cells_or_designs>  true |
| The logic positions of registers may be modified unless expressly prohibited by above specs | ？ |  |  |
| The design is timing-critical |  | set_cost_priority -delay | 设置综合中时序优先 |
| Design rule constraints must not cause timing violations | report_constraint -all_violators |  |  |
| Scan insertion will be performed by the Test group after the design has met these specifications | ？ | compile_ultra  -scan  -timing -retime | 检查约束是否设置成功 |

## Check Constraints

1. report_path_group
    
    ![Untitled](imgs/Untitled%206.png)
    
2. get_attribute [get_designs “PIPELINE”] optimize_registers
    
    ![Untitled](imgs/Untitled%207.png)
    
3. get_attribute [get_designs “INPUT”] ungroup
    
    ![Untitled](imgs/Untitled%208.png)
    
4. get_attribute [get_cells I_MIDDLE/I_PIPELINE/z_reg*] dont_retime
    
    ![Untitled](imgs/Untitled%209.png)
    
5. get_attribute [get_cells I_MIDDLE/I_DONT_PIPELINE] dont_retime
    
    ![Untitled](imgs/Untitled%2010.png)
    
6. get_attribute [get_designs “STOTO”] cost_priority(查看综合中是否是设置建立时间冲突的优先级高于 DRC 冲突)
    
    ![Untitled](imgs/Untitled%2011.png)
    
    ![Untitled](imgs/Untitled%2012.png)
    

## Compile

### compile_ultra命令

- syntax
    
    ![Untitled](imgs/Untitled%2013.png)
    
    -incremental : 使用增量编译，DC只做门级优化，不会回到GTECH
    
    -scan : 做可测试(DFT)编辑
    
    -exact_map
    
    -no_autoungroup : 关掉自动取消划分特性
    
    -no_seq_output_inversion
    
    -no_boundary_optimization ：不作边界优化
    
    -no_design_rule | -only_design_rule
    
    -timing_high_effort_script | -area_high_effort_script ：时序优化 | 面积优化
    
    -top
    
    -retime ： 当有一个路径不满足，而相邻的路径满足要求时，DC会**进行路径间的逻辑迁移**，以同时满足两条路径的要求。（为了让某些寄存器不要被DC更改，通过命令set_dont_retime)
    
    -gate_clock
    
    -self_gating
    
    -check_only
    
    -congestion
    
    -spg
    
    -no_auto_layer_optimization
    
    **-**no_uniquify : 加速含多次例化模块的设计的运行时间
    
- 在**DC Ultra（或者DC的拓扑模式下）**中，我们可以用**Behavioral ReTiming(简称BRT)技术**，对**门级网表的时序**进行优化，也可以对**寄存器的面积**进行优化。BRT通过对门级网表进行**管道传递(pipeline)（或者称之为流水线）**，使设计的传输量(throughput)更快。BRT有两个命令:
    
    ***optimize_registers*** ：适用于**包含寄存器**的门级网表（不是compile_ultra的开关选项）。
    
    e.g: 将后级组合逻辑延时长的路径移到前级，满足时序要求
    
    ![Untitled](imgs/Untitled%2014.png)
    
    ***pipeline_design*** ：适用于**纯组合电路**的门级网表。
    
- 使用**compile_ultra**命令时，如使用下面变量的设置，所有的**DesignWare层次**自动地被取消：
    
    **set  compile_ultra_ungroup_dw  true** (默认值为true)
    
- 使用compile_ultra命令时，使用下面的变量设置，如果设计中有一些模块的规模小于或等于变量的值，模块层次被自动取消：
    
    **set  compile_auto_ungroup_delay_num_cells**   **100**(默认值=500)
    
- 为了使设计的结果最优化，我们建议将**compile_ultra命令和DesignWare library一起使用**

此外，

1. 查看各个路径组分别的时序报告：redirect -tee -file rt_compile_ultra.rpt {report_timing}
    1. clk group
        
        ![Untitled](imgs/Untitled%2015.png)
        
        slack是0，证明时序
        
    2. COMBO group
        
        ![Untitled](imgs/Untitled%2016.png)
        
    3. INPUTS group
        
        ![Untitled](imgs/Untitled%2017.png)
        
        INPUTS时序违例了
        
    4. OUTPUTS group
        
        ？
        
2. 查看子模块PIPELINE进行optimize_registers之后被移动的寄存器
    
    ![Untitled](imgs/Untitled%2018.png)
    
3. 查看是否有被打散的模块
    
    ![Untitled](imgs/Untitled%2019.png)
    
4. 查看寄存器是否被移动（返回值证明没有移动，反之证明已被移动）
    
    ![Untitled](imgs/Untitled%2020.png)
    
5. 打开gui界面
    1. 在左上角设置了一个placement blockage
        
        ![Untitled](imgs/Untitled%2021.png)
        
    2. cells界面打开标准单元
        
        ![Untitled](imgs/Untitled%2022.png)
        
        可以看到标准单元之间有overlap，因为DC-Topo使用“coarse placement” algorithm for quicker placement, Coarse placement is good enough for purposes of estimating the interconnect or net parasitic R/C’s.


### Appendix
##### compile_ultra指令
```tcl
2.  Synopsys Commands                                        Command Reference
                                 compile_ultra

NAME
       compile_ultra
              Performs  a high-effort compile on the current design for better
              quality of results (QoR).

SYNTAX
       status compile_ultra
               [-incremental]
               [-scan]
               [-exact_map]
               [-no_autoungroup]
               [-no_seq_output_inversion]
               [-no_boundary_optimization]
               [-no_design_rule | -only_design_rule]
               [-timing_high_effort_script
                | -area_high_effort_script]
               [-top]
               [-retime]
               [-gate_clock]
               [-self_gating]
               [-check_only]
               [-congestion]
               [-spg]
               [-layer_optimization]

ARGUMENTS
       -incremental
              Runs compile_ultra in  incremental  mode.   In  the  incremental
              mode, the tool does not run the mapping or implementation selec-
              tion stages.

       -scan  Enables the examination of the impact of scan insertion on  mis-
              sion-mode  constraints  during optimization, as in a normal com-
              pile.  Use this option to replace all sequential elements during
              optimization.   Some  scan-replaced sequential cells may be con-
              verted to nonscan cells later  in  the  test  synthesis  process
              because  of  test  design-rule violations or explicit specifica-
              tions.

       -exact_map
              Specifies that sequential cells are mapped exactly as  indicated
              in the HDL code.  Use of the -exact_map option does not mean the
              QN pin won't be used in the mapped sequential element.

       -no_autoungroup
              Specifies that automatic ungrouping is completely disabled.  All
              hierarchies are preserved unless otherwise specified.

       -no_seq_output_inversion
              Disables  sequential  output inversion.  The phase sequential of
              all sequential elements is the same as in the RTL.  Without this
              option, compile_ultra is free to invert sequential elements dur-
              ing mapping and optimization.  For more information, see the man
              page for the compile_seqmap_enable_output_inversion variable.

       -no_boundary_optimization
              Specifies  that  no  hierarchical boundary optimization is to be
              performed.  By default, boundary optimization is turned on  dur-
              ing compile_ultra activity.

       -no_design_rule
              Determines  whether  the  command  fixes  design rule violations
              before exiting.  The -no_design_rule option  specifies  for  the
              command  to  exit  before  fixing  design  rule violations, thus
              allowing you to check the results in a constraint report  before
              fixing  the  violations.   The default is to perform both design
              rule fixing and mapping optimizations before exiting.

              The -no_design_rule and -only_design_rule options  are  mutually
              exclusive.  Use only one option.

       -only_design_rule
              Determines  whether  the  command  fixes  design rule violations
              before exiting.  The -only_design_rule option specifies for  the
              command  to  perform  only  design rule fixing; that is, mapping
              optimizations are not performed.  The default is to perform both
              design rule fixing and mapping optimizations before exiting.

              The  -no_design_rule  and -only_design_rule options are mutually
              exclusive.  Use only one option.  The  -only_design_rule  option
              can be used only with the -incremental option.

       -timing_high_effort_script
              Runs  a  strategy intended to improve the resulting delay of the
              design, possibly at the cost of additional runtime.  The  strat-
              egy  can  make  changes  to variables or constraints that modify
              compile_ultra behavior and perform additional passes to  achieve
              better delay.

       -area_high_effort_script
              Runs  a  strategy  intended to improve the resulting area of the
              design, possibly at the cost of additional runtime.  The  strat-
              egy  can  make  changes  to variables or constraints that modify
              compile_ultra behavior and perform additional passes to  achieve
              better  area.  By default, compile_ultra runs this option.  This
              option is available in the tool to support backward  compatibil-
              ity with existing scripts.

       -top   Fixes  design  rule and top-level timing violations in a design.
              By default, this option fixes all design  rule  violations,  but
              only those timing violations whose paths cross top-level hierar-
              chical boundaries.  If you want this option to fix timing viola-
              tions  for  all paths, set the compile_top_all_paths variable to
              true.

       -retime
              Uses the adaptive  retiming  algorithm  during  optimization  to
              improve  delay.  This option is ignored if the -only_design_rule
              option or the -top option is chosen at the same time.

       -gate_clock
              Enables clock gating optimization: clock gates are automatically
              inserted  or removed.  If the power_driven_clock_gating variable
              is set to true, the  optimization  is  based  on  the  switching
              activity   and   dynamic  power  of  the  register  banks.   The
              -gate_clock option  cannot  be  used  in  combination  with  the
              -only_design_rule option.  When used with the -exact_map option,
              it might not be possible to  honor  the  -exact_map  option  for
              those  registers  that  are involved with clock gating optimiza-
              tion.

              A clock gating cell is not modified or removed if it or its par-
              ent   hierarchical   cell   is   marked   dont_touch   with  the
              set_dont_touch command.

       -self_gating
              Enables the execution of XOR self-gating insertion.

              Self gating is an XOR based clock gating  technique  that  opti-
              mizes  dynamic  power by gating the clock signal in those cycles
              in which the data saved in  a  register  remains  unchanged.  An
              enable  condition  is computed by comparing the stored data with
              the new data arriving at the data pin, and that signal  is  used
              to drive the inserted self-gating cell.

              A  self-gating  cell  can  be shared across several registers by
              creating a combined enable condition so that the area and  power
              overhead due to the inserted cells is minimized.

              The  selection of registers to be gated and the grouping of them
              to form the self-gating banks are driven by the switching activ-
              ity at the registers' data pins, the timing slack available, and
              the physical proximity between the registers to be grouped.

              This option is only supported in Design  Compiler  topographical
              mode.

              The  -self_gating  option cannot be used in combination with the
              -only_design_rule option.

       -check_only
              Checks whether the design and libraries have all the  data  that
              compile_ultra  requires  to  run  successfully.   This option is
              available only in Design Compiler topographical mode.

       -congestion
              This option will be obsolete in a future release. See  the  -spg
              option for information about congestion optimization.

       -spg   Enables  physical  guidance and congestion optimization. Conges-
              tion optimization reduces routing-related congestion.   Physical
              guidance enables Design Compiler Graphical to save coarse place-
              ment information and pass this coarse placement  information  to
              IC  Compiler.  With this coarse placement, IC Compiler can begin
              the implementation flow with the place_opt command.  This option
              is  available  only  in  Design Compiler topographical mode.  IC
              Compiler no longer needs to recreate  the  coarse  placement  by
              running  commands  such as create_placement, remove_buffer_tree,
              or psynopt. By using the Design Compiler coarse placement  as  a
              starting  point for placement, runtime and area correlation with
              IC Compiler are improved.

       -layer_optimization
              Specifies that Design Compiler Graphical  consider  layer  opti-
              mization when you run compile_ultra -spg. If you don't specify a
              net search pattern or  associated  routing  constraint  pattern,
              Design Compiler Graphical performs automatic layer optimization,
              which automatically assigns nets to the two available upper lay-
              ers to get the best post-route correlation with
               IC Compiler. The layer assignments are preserved so that subse-
              quent compile_ultra -incremental runs use the layer  assignments
              from  the  initial  compile_ultra  -layer_optimization -spg run.
              This optimization is mutually exclusive with pattern-based layer
              optimization.

              Alternatively,  you  can  define a net search pattern using cre-
              ate_net_search_pattern and define associated minimum and maximum
              routing  layer  constraints  for  the  search  pattern using the
              set_net_search_pattern_delay_estimation_options command.  Design
              Compiler  invokes  net  pattern  identification  after the high-
              fanout synthesis step in compile_ultra, and assigns the  minimum
              and  maximum  constraints  to the matching nets.  The subsequent
              optimizations consider the effects of the constraints (for exam-
              ple,  unit  resistance  and  capacitance values of matching nets
              will change) during buffering and buffer removal. You can define
              as  many net search patterns and associated layer constraints as
              needed. In general, however, it is  recommended  to  start  with
              very  long  nets  (for  example, 500 um) with top routing layers
              (for example, M7 and M8). You should consider this  option  when
              your  design  shows  significant  unit resistance variation (see
              RCEX-011 resistance values) across all available routing layers.

              You  must use the -spg option because layer optimization is sup-
              ported only in the Design Compiler physical guidance flow. Layer
              optimization  with  the -layer_optimization option is not avail-
              able in incremental mode.  Therefore, you cannot use the -incre-
              mental option.

DESCRIPTION
       The compile_ultra command performs a high-effort compile on the current
       design for better quality of results (QoR).  As with the  compile  com-
       mand, optimization is controlled by constraints that you specify on the
       design.  This command is targeted toward high-performance designs  with
       very  tight timing constraints.  It provides you with a simple approach
       to achieve critical  delay  optimization.   The  compile_ultra  command
       packages  all  the  DC  Ultra features and enables them by default.  It
       requires a DC Ultra license plus a DesignWare Foundation license.  This
       command  provides the best strategy for optimum overall QoR and perfor-
       mance.

       When used  in  conjunction  with  the  set_host_options  command,  com-
       pile_ultra  uses  up  to  the user-specified number of CPU cores on the
       same computer for parallel  execution.   See  the  description  of  the
       -max_cores  option  in  the set_host_options man page for more informa-
       tion.

       This command can be used in the same manner as the compile command.

       By default, compile_ultra incorporates two ungrouping phases for design
       hierarchies.   The  first phase is performed before "Pass1 Mapping" and
       attempts to ungroup small design hierarchies.   This  first  ungrouping
       phase can be turned off using the following command:

         set compile_ultra_ungroup_small_hierarchies false

       The  second ungrouping phase is performed during "Mapping Optimization"
       and applies a delay-based ungrouping strategy for  design  hierarchies.
       You  can  set  variables  to control the second ungrouping phase in the
       same manner as with compile -auto_ungroup delay, for example, with  the
       compile_auto_ungroup_delay_num_cells variable.  If you need to preserve
       all design hierarchies, use the -no_autoungroup option.

       By default, if dw_foundation.sldb is not in the synthetic_library list,
       and  the  DesignWare  license  is  successfully checked out, dw_founda-
       tion.sldb is automatically added to the  synthetic_library  to  utilize
       the  QoR  benefit  provided  by  the licensed DesignWare architectures.
       This behavior occurs in the current  command  only,  and  it  does  not
       affect the user-specified synthetic_library and link_library list.

       By default, all DesignWare hierarchies are unconditionally ungrouped in
       the second pass of compile.  You can set  the  compile_ultra_ungroup_dw
       variable to control the ungrouping process of DesignWare components.

       By  default,  hierarchical  boundary  optimization  is performed on the
       design.  This can change the function of the  design  so  that  it  can
       operate  only in its current environment.  If input or output ports are
       complemented as a result of this optimization, port names  are  changed
       according   to  the  port_complement_naming_style  variable.   Use  the
       -no_boundary_optimization option to turn off the boundary  optimization
       feature.

       Regardless  of  the  options used, compile_ultra sets the value for the
       following environment variables:

         hlo_resource_allocation = constraint_driven
         hlo_resource_implementation = use_fastest
         hlo_minimize_tree_delay = true
         compile_use_low_timing_effort = false
         compile_implementation_selection = true

       The -timing_high_effort_script   and  -area_high_effort_script  options
       run  prepared  scripts  intended  to  improve  the delay or area of the
       design.  Note that the tool runs the -area_high_effort_script option by
       default.   The scripts apply a compile strategy that can turn on or off
       different optimization features depending on the optimization goal  and
       can  make  temporary  changes  to optimization constraints.  Therefore,
       these scripts may override additional variables not  mentioned  in  the
       previous  paragraph.  Some variable settings may persist after the com-
       pile_ultra command completes, so that subsequent  incremental  compiles
       run with the same settings.  Because the scripts can perform additional
       compile passes,  the  compile_ultra  command  runtime  might  increase.
       These   two   options  cannot  be  used  with  the  -no_design_rule  or
       -only_design_rule options.

       By default, the tool applies a compile strategy intended to improve the
       resulting  area  of the design, possibly at the cost of additional run-
       time.  The strategy can make changes to variables or  constraints  that
       modify  compile_ultra behavior and perform additional passes to achieve
       better area.

EXAMPLES
       The following example turns off boundary optimization for cell U1:

         prompt> set_boundary_optimization [get_cells U1] false
         prompt> compile_ultra
```