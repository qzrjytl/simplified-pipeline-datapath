# Simplified Five-Stage Pipeline Datapath

## 项目概述

本项目实现了一个简化的五级流水线数据通路设计，用于演示计算机体系结构中的流水线处理原理。

## 架构设计

### 五级流水线阶段
1. **IF (Instruction Fetch)** - 指令取得
2. **ID (Instruction Decode)** - 指令译码
3. **EX (Execute)** - 执行
4. **MEM (Memory Access)** - 存储访问
5. **WB (Write Back)** - 写回

### 数据通路组件

| 组件 | 位宽 | 说明 |
|------|------|------|
| R1-R5 | 16位 | 数据寄存器 |
| ALU | 16位 | 算术逻辑单元 |
| MEM | 16位 | 存储器 |
| WB | 2位 | 写回部件 |

### 操作类型定义

| op_type | 位宽 | 功能描述 |
|---------|------|----------|
| NOP | 2'b00 | 空操作 |
| ALU | 2'b01 | ALU操作，支持 rd = rs op ry |
| LOAD | 2'b10 | LOAD操作，从内存加载 |
| STORE | 2'b11 | STORE操作，存储到内存 |

### ALU操作码

| alu_op | 操作 | 说明 |
|--------|------|------|
| 3'b000 | + | 加法 |
| 3'b001 | - | 减法 |
| 3'b010 | * | 乘法 |
| 3'b011 | / | 除法 |
| 3'b100 | & | 按位与 |

## 文件结构

```
Simplified-Pipeline-Datapath/
├── README.md                          # 项目说明
├── docs/
│   └── design_spec.md                # 设计规范
├── rtl/
│   ├── pipeline_datapath.v           # 主流水线模块
│   ├── alu.v                         # ALU模块
│   ├── control_unit.v                # 控制单元
│   ├── register_file.v               # 寄存器堆
│   ├── memory.v                      # 存储器模块
│   └── pipeline_registers.v          # 流水线寄存器
├── tb/
│   ├── pipeline_datapath_tb.v        # 主测试台
│   ├── test_cases.v                  # 测试用例
│   └── wave.gtkw                     # 波形配置文件
└── sim/
    └── run_sim.sh                    # 仿真脚本
```

## 关键设计特性

### 数据转发 (Data Forwarding)
- EX阶段转发到EX阶段
- MEM阶段转发到EX阶段
- 支持多种冲突场景

### 冲突处理 (Hazard Resolution)
- **结构冲突**: 通过合理的时钟设计避免
- **数据冲突**: 通过转发和阻塞处理
- **控制冲突**: 通过预测和分支处理

### 控制信号

| 控制信号 | 说明 |
|---------|------|
| valid | 有效标志 |
| op_type | 操作类型 |
| rs1, rs2, rd | 源/目标寄存器 |
| imm | 立即数 |
| alu_op | ALU操作码 |
| byte_en | 字节使能 |

## 使用说明

### 编译
```bash
cd sim
bash run_sim.sh
```

### 仿真
仿真会自动生成波形文件供分析。

## 测试用例

详见 `tb/test_cases.v` 中的完整测试用例。

### 示例：R4 = R1 + R2

```
周期 1: R4 = R1 + R2  (valid=1, op_type=2'b01, alu_op=3'b000)
周期 2: Mem[R1+0] = R3 (STORE操作)
周期 3: R5 = Mem[R1+0] (LOAD操作)
```

## 性能指标

- **吞吐量**: 理想情况下每周期1条指令
- **延迟**: 5个周期（从IF到WB）
- **数据通路宽度**: 16位

## 注意事项

1. 所有数据初始化为特定值，详见规范文档
2. NOP操作不修改寄存器状态
3. 转发路径优先级：EX>MEM>无转发
4. STORE操作在第5周期后执行，LOAD操作在第6周期获取结果
5. 在第2、3周期的STORE与LOAD使用同一地址Mem[4]，STORE在第5周期写入存储器，LOAD在第6周期读出，写在之前一拍，结果正确。

## 参考文档

- `docs/design_spec.md` - 完整设计规范
- `rtl/` - RTL实现文件
- `tb/` - 测试文件和用例

## 许可证

MIT License