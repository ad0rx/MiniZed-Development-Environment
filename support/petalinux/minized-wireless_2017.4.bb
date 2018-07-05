SUMMARY = "minized-wireless:  Wi-Fi/BT drivers and firmware for the Murata 1DX module"
#SECTION = "PETALINUX/modules"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = " \
	git://github.com/murata-wireless/cyw-fmac-fw;protocol=http;branch=orga;destsuffix=cyw-fmac-fw \
	git://github.com/murata-wireless/cyw-fmac-nvram;protocol=http;branch=orga;destsuffix=cyw-fmac-nvram \
	git://github.com/murata-wireless/cyw-bt-patch;protocol=http;branch=morty-orga;destsuffix=cyw-bt-patch \
	git://github.com/murata-wireless/cyw-fmac-utils-imx32;protocol=http;branch=orga;destsuffix=cyw-fmac-utils-imx32 \
"

SRCREV_cyw-fmac-fw = "2242fd3f67a913fbfff8678cc8f7761629dca8ca"
SRCREV_cyw-fmac-nvram = "d12c2ac1b93941eaa03063bb7cb3c1ee1aa1b7d0"
SRCREV_cyw-bt-patch = "9216e0d9f778009b5667d032886dfd49174c4b3a"
SRCREV_cyw-fmac-utils-imx32 = "060688dfe76df98751207c8146268ce7fd80b6ab"

SRCREV_default = "${AUTOREV}"

DEPENDS = "libnl virtual/kernel"

S = "${WORKDIR}"

KERNEL_VERSION = "${@base_read_file('${STAGING_KERNEL_BUILDDIR}/kernel-abiversion')}"


do_install() {
	install -d ${D}/lib/firmware/brcm
	install -d ${D}/etc/firmware
	install -d ${D}/usr/bin

	install -m 644 ${S}/cyw-fmac-fw/brcmfmac43430-sdio.bin ${D}/lib/firmware/brcm/brcmfmac43430-sdio.bin
	install -m 644 ${S}/cyw-fmac-nvram/brcmfmac43430-sdio.1DX.txt ${D}/lib/firmware/brcm/brcmfmac43430-sdio.txt
	install -m 644 ${S}/cyw-bt-patch/CYW43430A1.1DX.hcd ${D}/etc/firmware/BCM43430A1.1DX.hcd
	install -m 755 ${S}/cyw-fmac-utils-imx32/wl ${D}/usr/bin/wl
}

PACKAGES =+ "${PN}-mfgtest"

FILES_${PN} = " \
	/lib/firmware/brcm/brcmfmac43430-sdio.bin \
	/lib/firmware/brcm/brcmfmac43430-sdio.txt \
	/etc/firmware/BCM43430A1.1DX.hcd \
"

FILES_${PN}-mfgtest = " \
	/usr/bin/wl \
"

