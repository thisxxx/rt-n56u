#
# mihomo (Clash.Meta) 静态二进制集成模块
#
# 说明:
#   1) mihomo 是官方预编译的 MIPS32r2 LE softfloat 全静态二进制
#      (无 PT_INTERP, 不依赖 uClibc), 不参与交叉编译,
#      直接安装进 ROMFS(squashfs)
#   2) 【重要】本目录放的是【未压缩的原始二进制】, 30,802,086 字节 (29.38 MiB)。
#      不要换成 UPX 版本!
#      squashfs 是 xz 分块压缩, 内核 mmap 后按需解压代码页, 运行时只驻留
#      真正被访问到的那部分页面 (实测约占镜像的 20~35%);
#      而 UPX 版在 exec 时要把整个 29.38 MiB 解压到匿名内存,
#      在 128MB RAM / 无 swap 的 R4A 上必然 OOM。
#      两者 flash 占用几乎一样 (xz 5.99 MiB vs UPX 6.04 MiB), 内存却差 4 倍。
#   3) 这已经是 strip 过的 Go 二进制, 不需要也不能再 strip
#   4) 由 CONFIG_FIRMWARE_INCLUDE_MIHOMO=y 控制是否打入固件
#
THISDIR = $(shell pwd)

all:

romfs:
	# -S: 禁止 romfs-inst.sh 对二进制做 strip (Go 二进制 strip 有风险且无意义)
	# -p +x: 显式补上可执行权限
	$(ROMFSINST) -S -p +x $(THISDIR)/mihomo /usr/bin/mihomo
	$(ROMFSINST) -S -p +x $(THISDIR)/mihomo-start /usr/bin/mihomo-start
	# yacd 面板静态资源 (45 个文件, 1,135,385 B 原始 / squashfs 内约 0.40 MiB)
	# 【不要打成 tar.gz】: squashfs 自己就是 xz 分块压缩, 再套一层压缩会让
	# xz 失去跨文件压缩上下文, 压缩率反而变差, 白占约 0.5 MiB。
	# romfs-inst.sh 支持目录源: src 是目录时递归 cpio 进 $(ROMFSDIR)$(dst)
	# (-d 只用于确保 dst 的父目录存在)
	$(ROMFSINST) -d -S $(THISDIR)/ui /usr/share/mihomo/ui
	# geo 数据(精简版): 只含 CN/JP 与常用集合
	# 为什么必须预置: mihomo 在 -d 目录下找不到 geoip.metadb 时, 会在解析到 GEOIP 规则的那一刻
	# 去 GitHub 拉全量库(8.04 MiB), 并整份驻留内存 —— 128MB 机器吃不住, 国内还常被墙;
	# 拉不到就直接报错, 整个配置加载失败。预置精简版后, GEOIP/GEOSITE 规则完全离线可用。
	$(ROMFSINST) -S $(THISDIR)/geoip.metadb /usr/share/mihomo/geoip.metadb
	$(ROMFSINST) -S $(THISDIR)/geosite.dat /usr/share/mihomo/geosite.dat

clean:
	@true
