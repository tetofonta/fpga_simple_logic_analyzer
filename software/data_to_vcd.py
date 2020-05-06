data = [0x00000077, 0x00008037, 0x0000E077, 0x00001837, 0x00004C77, 0x0000C237, 0x0000D277, 0x00002A37, 0x0000B677, 0x00006E37, 0x0000E177]


def bit(a, x):
    return (a & (1 << x)) >> x


def bitp(a, x, y):
    return bit(a, x) << y


def reverse(a):
    r = 0
    for i in range(4):
        for j in range(8):
            r |= bitp(a, i*8+j, (i+1)*8 - j - 1)
    return r


vcd = open("test.vcd", "w")
vcd.write("$date\n"
          "\t01/01/1970\n"
          "$end\n$version\n"
          "\ttetofonta_logic_analizer\n"
          "$end\n"
          "$timescale 1us $end\n"
          "$scope module ANALYSIS $end\n"
          "$var wire 8 0 pa[7:0] $end\n"
          "$var wire 8 1 pb[7:0] $end\n"
          "$var wire 8 2 pc[7:0] $end\n"
          "$var wire 8 3 pd[7:0] $end\n"
          "$dumpvars\n"
          "bxxxxxxxx 0\n"
          "bxxxxxxxx 1\n"
          "bxxxxxxxx 2\n"
          "bxxxxxxxx 3\n"
          "$end\n")

for i in data:
    # i = reverse(i)
    channel = (i >> 29) & 3
    time = (i >> 7) & 0x3FFFFF
    value = i & 0xFF
    vcd.write("#{}\nb{} {}\n".format(time, "{0:08b}".format(value), channel))

vcd.close()