# EasyTier 模块（骨架）

本目录只放 EasyTier 的静态二进制，不参与交叉编译。

## 用法

1. 编译/下载 **mipsle softfloat** 版 `easytier-core`（MIPS32r2 LE，全静态，无 PT_INTERP）。
2. 把二进制放到本目录，文件名 **必须** 是 `easytier-core`（无扩展名）。
3. 在 `trunk/configs/templates/MI-R4A.config` 里把

   ```
   # CONFIG_FIRMWARE_INCLUDE_EASYTIER is not set
   ```

   改成

   ```
   CONFIG_FIRMWARE_INCLUDE_EASYTIER=y
   ```

4. 提交并触发云编译即可，装配规则见本目录 `Makefile`：
   装到 `/usr/bin/easytier-core`。

## 关键：必须用未压缩的原始二进制，不要 UPX

| 形态 | 文件体积 | 进 squashfs(xz) 后 | 运行时内存 |
|---|---|---|---|
| 未压缩 | 10.01 MiB | 约 2.28 MiB | 按需分页，只驻留被访问的代码页 |
| UPX 压缩 | 2.30 MiB | 约 2.30 MiB | exec 时整块解压 ≈10 MiB 到匿名内存 |

结论：
- flash 占用基本一样（xz 分块压缩已经把差距吃掉了）；
- 但 UPX 版每次启动都要多占约 10 MiB 匿名内存，R4A 只有 128MB RAM 且无 swap，
  会直接把内存打爆（mihomo 之前的"跑一会就死"就是这么来的）。
- 所以：**放未压缩的原始二进制，让 squashfs 去做压缩。**

## 运行时约定（由 /usr/bin/mihomo-start 托管，可选）

`mihomo-start` 在启动时会顺带检查：

- `/usr/bin/easytier-core` 存在，且
- `/etc/storage/easytier/config.toml` 存在

两个条件都满足才会拉起 EasyTier，日志写 `/tmp/easytier.log`。
配置槽位（`/etc/storage` 只有 512 KiB，配置文件请保持精简）：

```
/etc/storage/easytier/config.toml       # EasyTier 的 -c 配置
```

手动控制：

```sh
mihomo-start et-start     # 只启动 EasyTier
mihomo-start et-stop      # 只停止 EasyTier
```

## 与 mihomo 共存

`mihomo-start` 下发的 iptables 规则只挂在 `PREROUTING`（接管 LAN 侧转发流量），
**不碰 `OUTPUT` 链**。EasyTier 是本机进程，出站走 `OUTPUT`，
所以天然不会被 mihomo 的透明代理劫持，两者的 tun/路由不会打架。
