#!/bin/sh
# SPDX-License-Identifier: Zlib
#
# Fetch the third-party libretro cores used by retrods, pinned to known-good
# commits, into third_party/. Safe to re-run; existing checkouts are left alone.

set -eu

cd "$(dirname "$0")/.."
mkdir -p third_party

fetch() {
    dir="$1"
    repo="$2"
    ref="$3"
    org="${4:-libretro}"

    if [ -d "third_party/$dir" ] && [ -n "$(ls -A "third_party/$dir" 2>/dev/null)" ]; then
        echo "third_party/$dir: present"
        return
    fi

    echo "third_party/$dir: cloning $org/$repo @ $ref"
    git clone --quiet --recursive "https://github.com/$org/$repo.git" "third_party/$dir"
    git -C "third_party/$dir" checkout --quiet "$ref"
    git -C "third_party/$dir" submodule update --init --recursive --quiet
}

# Shared libretro-common. Cores vendor their own copies, but its symbols are not
# renamed per core, so exactly this copy is compiled once and linked into every
# build (see common.mk and core_rules.mk).
fetch libretro-common libretro-common 2b96a82bd8479bb3547d271e1eefadc82dd2161e

#                                  repo                       pinned commit
fetch smsplus                     smsplus-gx                 3844b46caa926b6494987b97da63092818c4ddef
fetch prosystem-libretro          prosystem-libretro         8a88014287c7a01cd568067e5a557d0a2b2a051f
fetch stella2014-libretro         stella2014-libretro        7d1361e407e63f29e52892655069e5fb4096e691
fetch PokeMini                    PokeMini                   132111b76343559860532a1ccc094f93f1ed5650
fetch libretro-o2em               libretro-o2em              679d6fec04963f6e70a7ec217e3d0ebb1fe472fc
fetch freeintv                    freeintv                   ef3e0fe322bec62a7f916c0bb0834c08c348d0b4
fetch libretro-handy              libretro-handy             bc55d462f0b2d6b073ea93dc552ebd73cec60fd1
fetch gambatte-libretro           gambatte-libretro          d9d6cd06382d1ced30de34d56d3609452323dab1
fetch libretro-fceumm             libretro-fceumm            7a542dab1e87679921962a9f056186eca425c0c2
fetch beetle-ngp-libretro         beetle-ngp-libretro        a50d5ac288a81f2104ddf43195a4efdd15c72227
fetch beetle-wswan-libretro       beetle-wswan-libretro      4b01295838ea89e3f1355bbe4cb5cf98aa6108cd
fetch beetle-vb-libretro          beetle-vb-libretro         83ed42608601fb7b01d41e4f8fb2007a37b8c84e
fetch snes9x2002                 snes9x2002                6ffbf9ef4f0063e1f1b78a40d10c50fc52f2524c
fetch beetle-pce-fast-libretro    beetle-pce-fast-libretro   3f946f277aef3aa99a95551618bbcd1dd2bda0d9

fetch QuickNES_Core                    QuickNES_Core             26bb785c9deddb66a17717b21bb4e328f03ade32
fetch libretro-cap32                   libretro-cap32            0cdc914749baade70ffbd56c1685a836465eda05
fetch libretro-vecx                    libretro-vecx             8f671cc9d737f2890c3ce19e177e2984dcae121f
fetch beetle-supergrafx-libretro       beetle-supergrafx-libretro 9c11dcd213a79d57d2c86313971631af801f2cdc
fetch freechaf		freechaf	76c7a84f1f7e80f3e6f2bba96fe100cb24e99124
fetch gw-libretro		gw-libretro	91d599b951e7bfe7e040347f58667cba20074adc
fetch beetle-gba-libretro		beetle-gba-libretro	b158166237b17253188cfdbe73a8a0b9fe4b3a8c
fetch gpsp		gpsp	5819380c2ffb0900219d700a382ee68c464ebb99
fetch snes9x2005		snes9x2005	a79dfe9047e7fec58808aefe48ad2bf499c7af11

fetch Potator                      Potator                    227c5f6f3ce74d32e9002ce24c1420288559a860
fetch fuse-libretro                fuse-libretro              e997e2bc32c888348f862f69f2c53babfedf7791

fetch libretro-atari800		libretro-atari800	4e7fbc73765c1a9670c7506616046ad1d4ccda51
fetch vice-libretro		vice-libretro	f63b56688f3133a2bb17499db9eebb7ab81df5f5

fetch fmsx-libretro		fmsx-libretro	4de11755ce4f196ac1c8a7bb20bb4eccbc87a7d4

fetch Genesis-Plus-GX		Genesis-Plus-GX		58c341487e5bfcf979ea68413c7987633adb0c56

echo
echo "applying local patches..."
sh scripts/apply-patches.sh

echo "cores/ describes how each one is built; see common.mk for CORES."

# The two cores retrods needed ports for, as separate projects: no libretro core
# existed for the TI-99/4A or for the Tandy CoCo / Dragon / MC-10. Both are
# ordinary libretro cores with their own CI and releases, fetched like the rest.
fetch ti99-libretro               ti99-libretro              29bb68a                          konsumer
fetch xroar-libretro              xroar-libretro             44be93e                          konsumer
