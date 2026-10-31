#
# mihomo (Clash.Meta) 静态二进制集成模块
#
# 说明:
#   1) mihomo-linux-mipsle-softfloat 是官方预编译的 MIPS32r2 LE softfloat
#      全静态二进制(UPX 压缩), 不参与交叉编译, 直接安装进 ROMFS(squashfs)
#   2) 未压缩体积约 6.04 MiB, 固件内运行时展开约 33 MiB 内存
#   3) 由 CONFIG_FIRMWARE_INCLUDE_MIHOMO=y 控制是否打入固件
#
THISDIR = $(shell pwd)

all:

romfs:
	# -S: 禁止 romfs-inst.sh 对二进制做 strip, 否则会破坏 UPX 压缩壳
	$(ROMFSINST) -S -p +x $(THISDIR)/mihomo-linux-mipsle-softfloat /usr/bin/mihomo
	$(ROMFSINST) -S -p +x $(THISDIR)/mihomo-start /usr/bin/mihomo-start

clean:
	@true
