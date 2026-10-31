#
# EasyTier 静态二进制集成模块
#
# 说明:
#   1) 本模块【只提供骨架】, 二进制需要你自己编译后放进来,
#      路径固定为 trunk/user/easytier/easytier-core
#   2) 必须是【未压缩的原始二进制】, 不要用 UPX 版本!
#      原因见 README.md: squashfs 按需分页, UPX 会整块解压到内存
#   3) 二进制不参与交叉编译, 直接安装进 ROMFS(squashfs)
#   4) 由 CONFIG_FIRMWARE_INCLUDE_EASYTIER=y 控制是否打入固件
#      (默认关闭, 打开前请先确认二进制已就位)
#
THISDIR = $(shell pwd)

all:

romfs:
	@if [ ! -f $(THISDIR)/easytier-core ]; then \
		echo "ERROR: $(THISDIR)/easytier-core 不存在"; \
		echo "       请把未压缩的 easytier-core (MIPS32r2 LE softfloat 静态二进制) 放到该目录,"; \
		echo "       或把 MI-R4A.config 里的 CONFIG_FIRMWARE_INCLUDE_EASYTIER 关掉"; \
		exit 1; \
	fi
	# -S: 禁止 romfs-inst.sh 对二进制做 strip (Go 二进制 strip 有风险且无意义)
	# -p +x: 显式补上可执行权限
	$(ROMFSINST) -S -p +x $(THISDIR)/easytier-core /usr/bin/easytier-core

clean:
	@true
