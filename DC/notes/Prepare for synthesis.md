# Prepare for synthesis

## Structure Partition for Synthesis

1. for Design Reuse
    1. Standardize interfaces
    2. Paramterize
2. Keeping Related Combinational Logic Together
    1. **Eliminate glue logic!(Glue logic is the combinational logic that connects blocks)**
3. Registering Block Outputs(Easily Constrain)
    1. Drive strength
    2. Delays
4. Partition logic with different design goals into separate blocks.
    
    e.g. Isolate Critical Logic
    
5. Partitioning by Compile Technique
    
    Compile Technique: Structure & Flatten
    
    Different logic is suited to different compile technique.
    
6. Keeping Sharable Resources Together
    
    DC can automatically share large resources, when they belong to the same block.
    
7. Keeping User-Defined Resources With the Logic They Drive
8. Isolating Special Functions

## HDL Coding for Synthesis