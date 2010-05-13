#!/usr/bin/ruby -w

=begin
  Create face2name configuration bundle.
  Called from command line, but also used in f2n Store

  by Winston Wolff of Carbon Five, for Cozy Bit Inc. May 2010

  Specs for Configuration Bundle:
     https://123.writeboard.com/c81a2c60a098b49d8
     (subversion)/face2name\docs\notes\config_bundle\config_bundle_spec.txt
     (subversion)/face2name\keys\config_bundles\how_to.txt

=end

require 'time'
require 'date'
require 'digest/sha1'
require 'digest/md5'
require 'tmpdir'
require 'find'
require 'fileutils'

def rails_root_fldr
  if defined? "Rails.root"
    Rails.root
  else
    File.dirname(File.dirname(File.expand_path(__FILE__)))
  end
end

# Generate a random activation code, appended with a checksum.
# See (subversion)/face2name/tests/activation/gen_activation_code.py
def activation_code()
  act_code = ''
  valid_set_ascii = ("A".."Z").to_a

  5.times do
    act_code << valid_set_ascii[ rand(valid_set_ascii.size-1) ]
  end  
  
  check_code = act_code.sum % valid_set_ascii.size + 65
  act_code += check_code.chr
  raise 'Assert: code should be 6 chars' unless act_code.length == 6
  
  return act_code
end

#  Input:
#    users = a two dimensional array, e.g.:
#     [
#       [ {name}, {email}, {filename of photo} ],
#       ...
#     ]
#     
#   Output: Returns a string which is the XML file contents.
def make_users_xml( attendees )
  # This data comes from users, so check inputs well.
  # !!!
  result_xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<Openfire>
"

  start_date = Time.now()
  modify_date = Time.now()

  for attendee_name, email, photo_filename in attendees do
    username = Digest::SHA1.hexdigest( email )

    
    act_code = activation_code()
    # TODO -- THIS IS FAKE PHOTO DATA.
    photo_u64_data = "/9j/4AAQSkZJRgABAQEASABIAAD/2wBDAAMCAgMCAgMDAwMEAwMEBQgFBQQEBQoH
BwYIDAoMDAsKCwsNDhIQDQ4RDgsLEBYQERMUFRUVDA8XGBYUGBIUFRT/2wBDAQME
BAUEBQkFBQkUDQsNFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQU
FBQUFBQUFBQUFBQUFBT/wAARCACgAKADAREAAhEBAxEB/8QAHQAAAgIDAQEBAAAA
AAAAAAAABgcEBQIDCAEACf/EAD0QAAIBAwIEBAMFCAEDBQEAAAECAwAEEQUhBhIx
QQcTUWEicYEIFDKh8BUjQpGxwdHhUkNichYkMzTxc//EABoBAAIDAQEAAAAAAAAA
AAAAAAIDAAEEBQb/xAAnEQACAgICAgICAgMBAAAAAAAAAQIRAyESMQRBE1EiMgVx
FEJhI//aAAwDAQACEQMRAD8AVei37WLhTkjtXHHp0F0esJLGDy5NBQdkG6jn1WUI
p29BRdFO2XumcHyGJSRscdutPhc2or2U1Sse3hxw5FYW8AMfLDGucdOZvU11JyWO
PFF4oOTtjPSUKFIChMdPas/Kzeo0SxOGXKLz7bAd/YUtyHRVGwMcdthv61nbNR8E
y2B2PegbDM1XyiPiJDHGOwNA2F2jF4wy7k+3tUsFohMArSNjp+dVYNGjb8fcd2FE
pFuJAv8AT0uslwq57KN60RlozTxp9AXr3CMokZoQPIwVIUAdd857H/FNutmRwBm9
4YmtYTcxqEC7Oox8X62psXYmUWio4P1qTw+4+tZZG5NN1PFteKDsCTiNyD3B2z6G
n9qjn5oe/ofl5H8RxWWTAgiIyNjNZGjanoptSuvIRie1HEBnFQtwrgEYrOWXOm2T
zuqKKpuiIaHCXBRuGQlSc98UIxINdW0OLQxYR4AeQl+meg/3W3xO3L6BmukGnDsg
TTVUkll2PNsflTMkrNuKIRxyAwISOcE+vb+9By1sdWyXazcwHN1ycb52oOVjkqLB
MSZDbY64pT2ORgX5TgAN75pTC67MTKR1bf0NUWmeS3AWL4pGUnIwB1oWyyuWcy/D
zHBOckYzQ22To2ZGNjk9RnemAkK6nKSMWZSgHXPf0xTFKuwGrIbXETZBwVJwexX/
ADWiLRlkmRtRXzLfCqr79cUabQppPsVnilpCPpzxISj8hGxwOY/hOa1QZhyRoavh
3rZ4q4K0TUZD++mtlEuf+a/C35g1myabRniggnteQEDpShoLcRW//t5CNtqOKBkc
qS8MTjfyicH0rM2EE/CXDMn3hTJHS3sJD34O02G0RQ64NAxiKPxE1VG4qWJBmO1i
VAB3J3NdLD+OP+we5lpwnOJLdyCSh6dxSZvZ0cfQVW08aQLuCB1zvigtJD6bZnHe
lpcLG7lTgkDYfWlOV9DUqLOG5kf/AKY+YYZxVWwkj6R5QrLzIuOgbJHtvQ7L0aPN
l8vYISTncH1+W1A2y0tmiaQuvMJVUnbrkY+VBfsMr0cqM+cpIyehxQomzB7+VcsZ
Aewz60TbL4lDqWsPGd2YL/yXcH/FROi+JpsNWiZwiZAI336H9f0rTCRlyRZOvLlU
RQHbHUdsHr+vnT0zO0A3G+pDUFuYpAORVCjJ7n+9asbswZkXPgPqgi4autPLhhaX
TcgHZX+L+uarPqSf2YojPfUFJ61mseUHEM4ktXxg7U6IqQLXvBKLFhU7elJaCPLT
h37oiuEIxQOhiLyzvo7cDJ6UlosWGuasdQ4i1VuxuOQPnoABXRjqCRcdtsK+EJzh
YEYGMjCkZG1Zch0MIwbG3+BcbZoIr2P9ktrVZcjmY43671GkxidEm1tyg6MO+4P5
UFB2zcUy4AIOx69qr+i60axByrgKfi32AzQP/hCNdxSLv5bFvXrQOwkyv+7vhsKW
LdVO2D7/AK7VYVorNSspmjPLiMjbpnB77UNBp0CV7DNHIcdzg8wzsOtDTsJuzKwt
QAAOVsfw9cU2GhEkbtYv1giLpghRjB7fr1rUjFk0K/WdQN1M+ZCOYHlJYbemfUVr
gc7IX/hHqDW+o6rGQAHiV2K9CwOMj6Giz/qmZI9sPZeIMXHKGrEPIWsa4fu7b0+D
FSHFPoqeSg5d6tkIFzoKi2c8oNJaDFnxRbzWiuYlIHtQ0QTMF3K2uahFISxaQnlA
3yewrSv1QyA3+DLCSCIGXILMMfy2rNN26OliVRGNaW3IqhyDtjHTA7Uaj9jLLRGj
RGywODjHTG2aGqLX2YpfCKR2MhOcAKP7fPrS26Grro3LdRSp8RHXcetCqC/o2BoS
NmAB22FVqiESdk5yABtsTmgYZpZoIl5yw/lU0VtlZdyW8uXxzMdsYOPyqtBbRR6h
pvnn4MsfXOatKyuVEKWymtRyqnN6kLjarVoG0wb1+AzQFwcPy4z7+laYq1ZhyvdC
c1R4vNmCzEsp/DjBP+N+1a46RzpbYW+EZEuoXHK3Mvkup26nKmpl/VCF2F95+6uz
86xPsaQNYusW7fKmxFs6iKCSFflRMiNL2oaJgd6WHQCcUabHyvtk0LLRz+dMWTxL
mt+XCllcgHHSn/6WMxrdDZg1LT9CtxdXs6RRjYZ3y3sBuflSYrZ0LFxxD9paKK+m
it4eSCMkcplUtt3bGcfXpWqrQl5KdFbd/az0ewtF821uHmGQw5/54OP70v42y35E
UStB+1Xw5rJjNu/Kz75kbCj0ywyCM9+3cCkzxNDoZozDSDxXtNWdRF5qs+wjZMFS
GwysOxB6/I1mlFo2wa6LccWzTxyFJWROXIwcd+nsfWktsdFI3DX8HmMoOADgHHX0
FV0yES54phJAlueTmAYJ0yMdx+VGi0vo1pxRAwY+cpCnDENjB9DRJWJk16MouLrV
cAzIgGMEsBg/OmJULckSBxnpt1OIvvEJc7cpbZqZxfYu16ZG1ayjubORUADH4i2d
h6imxqjNl7sRvGWkyafczSovwspOcdd/91oi9GCaoJvA6L7ze3jYwFjbYfQdavIr
iZ06Yd6ppzG4yM1n4NhORT6rpjPC4welMjjFuR0Xb6kvlKC1McbKUjP9pryN8VBw
GckDOuMXDFlIBqcCW1uhOXFhEviktwi5Y2xJyNs1clUaHYXcrArxVvbu84lNpEJV
gijCq4yUB3yRg9aBtJG6MWwFufCfhmOxN/rksUS5yZZZCh5vTOd/lS3ll6DWGD7Q
t+PfDzgiOJnlvr6zZlzGZrgW+3sJWUkdO3ejUsnsTKGIV9np2maDqazpqN192bIW
WWP92wOxBkjLDfbc0Tm/aKjjj3Fj14A1fUIIrdZLk3ICciXEbczEbcpLHrsoGevT
0zWaUkbYQkux48OyahqNtH8UcagKF5RyqB19Omaxto0ptEPiLWZbBJlErx4TAfOC
zDfOapU2FJ2hL8XeLlxY3ckpuHWRrflIj3+MFsEAZwdx026elbIwTRmllktCh1Tx
o4qWV/u8t3Dbg5EUScqnJORjBLDfrt861xjFI5+SeWT0bdL8R+NtXYI1reSgndQO
QOvowJYn9GifBCl8z9FxJxXxxoDi5mtp0jXGEklLfQHOSPmNvah/F9Df/RbY/fCX
7Rn7cuLbSNdBjkdQvnEdT2Jx1Pv371ajuypTtUMnj/RWu9IQhByxygkr15SCKKKE
T2rN3gfpTWlhqU7g7uEUnrjrTqtGKT2H1xaGVulVxBsr7vTyynajUQbDNb9hgAmr
cCWbJdSaOB2U/EFJGfXFU46Di/ySFZoHiVqN5LcQ60myuyrKncZ2yK5Hyzrs9u8O
NJRrRcDTx/6gt71JPNV7dzgdsEYrVCbnG2cTPhhiyVD2BXE9kbdXuJlLkZf4+p9A
KzcrGU06EJqvD3F3E2uyT/en0qOSXlSdcGWGDpyW/ZGO5Mh36AbCmYq7ZeSDa4p6
KDij7P2r2XEM1xwzDqM8d/boi3kAW5uoHUFXBZwWBOMhgRnmI2IFdFZIV+JxcmDN
f5Kyo0v7O93w9pN7dz2dxBqA8qOBLgLzuVzzvIik5ByBgjOxO2xrHlyR/VM6PieP
NPlJUMDw/wDDy9sbOK8hIS387yJI0DYjlxk4DAHl+Y/pWJzUtHUlHg9HYPhpwxby
cNwySqokZcn/AMqQo3YXFiy8f+FrfSOHrue2jJMIY8i/lQpVLYTVKzgzWtM1/UWv
7qYva2tty+bMgP4m2VF9T+uma6ScEqOfU5ukadP8FtQ1/hG51OMXaXsciN90JYvJ
FzYfB/ibG+PTOBT4Tg3TZl8jDlitIjaZwvxbp3ECWmkatfaezyKqWti8wCqAMlhI
T2BJJ29OoFPcYvs50Z5U6jZc3PHPGHDmoPY6wx1W3Dcq3M1r5Tvk9mA6jHcbnasz
jH/VnTjPKlU0G/CGmRXd9DqNuGEuc5IwR86FSrRbhbs7C0+6/a3AlvLcODPCi85Y
7nBxv9KdB8qZmyKk0aeE+MbHhHh931B47eJmaUtI3VRsNqVLyeL4xRtwfx0csfky
Mj8D/aS0DxC4ufQLOxeIYPk3uMLKw7Yo4Z25KM12M8v+MWPA8+P0NFkDdRXQPMm4
vgVGyEeW4I2zsdqBvQUe0B/7FiGo3fPGHiO+42rgvTPepfil/wAJ3Dxhe9vEtpRL
FGqx4B/A3UitEGnFuJyc6fyKy3vdETUIyJIxIuR8JGc0noZSIGq8ER31iqQIkUqb
qeTINMvWjOnUti91Twu1i6uWkjitpGzgOVZfbc5+dC5SZqhKKMNP8IbuGUS31wNi
MQ2yld/dqpQfcmOebVRQatoksNvBDcPzsXGAoxj0z6n50qVXSFxhe2M3hSF10xPg
VSBjA6KM9M96ao6RockkAnjQsN1p0tuwz5inbrnakyWy10IXSOFzYmQRKhieQTAN
GH5XAAzj6UKcW6kIlHj0brrRdZSQzJM17HksEB8tlz6AbCtG/Wy041tUUl9+27sS
ReVq783MORmLKc9d852xV817QDSXVGvTPCibWHDX9s5OAf3g6+5z3onPRnfYR6D4
Ux6fOxJLKuwLb4FKt1oNpNWg9tYDYaJcWhk+B4X5yR1OMjb6VtwvSOfnXYlbnRp+
OLq3vL25DWEYPJbKcjI9axyfHo7+FXCmFfgnwBBZ8UQ3oiEflFpBgfQf1pmD88qX
0D/JZPj8Pj9nRauK7VHhrMJJwO9RoiK65usHrQ0X0ZXsC/s6e5Vivwb/ADriZocW
z23i5PlhF/8AAd4VAgnnn5eUTsTntkbf3q8X6MT5cazRGHYzqYxzMACM7dajdA1Z
OV423DKxHvQ37FyxsiPLNIvKANu6n+1X8jfRaxpMzFtFASz/AByZzzNQt32NUaBu
6Jkvg+Q2+fi9fpVVsN9UH2gQmOx5dgRsAf13rRVIpOxYeKlnNd3ad4w3xhe6npn1
pElvY1uogJFatbz7fF06D8v6UiUSRYUwaJb3UQdE5Tg9TgAjtRK10U0aY7ZrdlRo
xgjJ5lG/89//ANqOb9gvGT4QnIV+EDqBkkgf3oVIHgYXLwxfAdwwJ5kGR1/Kmpgy
VIE9ZvmTZeYmRggUdcMcf3NbcWtnNy7dC84H4bbR9UutOjctFFLIA5/i3JzWGas9
IlcE0OPguy+6iSbAVeUINvqa6Xh42nKbPO/yuZSUMS9bCg3O3WuoecMnBaoGiPJa
89BRdG0oq2bRTuVgkXkJ/wCJ7GuV5UPy2en/AIzJ/wCf9FFqGnzcP28EcxEkLuWS
RNhg0iCcYtM1eVJZHGa+y3sNXHKjqwKMAuD1/XSlPYCCC3lilOZJVwRuBgZqlXsO
36RLF2ioFiP/AIkDeo39ES+zRclgvO5AcZB5iQAf81E0uwnvootEabUdTLlOW1Vm
RD3JA3+dNgm/yFz1oZVmqRxqBgKVG4/XSny6LjdAvxRZo8U3mxD4+hLZoe1skmIV
9RutD1AC7gAs5ZWRJB0DAnGT9KxZFxdodBKaGNp0iCyVouQ8xyVk9D3GTQWvQVfZ
nctE8UgcPyueoIDKatuyvZS3zrBzsrjlGTjmAIHrQVsl0D9/rjozNJIeQqQd/T19
KdHsRN/QNNqn32+tUhYysZebA3PsB/Otq1FnPrllSL6XTBol1PLNNF94dcQxKcsx
NZXH8j0EckeFJdB7o1sbfS7ZG/HyAn5mvQYYcYJHhvLyfJmlIlMoxTzIWAxQBI+5
ahDONlidWkj82MH4kPes+WHNX9G/xM/xSpvTK3xEYTaUJ7dwtqroxTHTfFc17lo7
eSLjjt/8BPT5/JkjGBtkkd/1/mswSZe2d/KSEVxkfES5HN6/U0ptmhMItMdmjDEZ
U7nO2c/r5VXsts3ahK7QsNk7jbYD5+veq/Z0EtIrZuO9L077pHbAeWo5CVH4T/ut
rmkkoiuDe2FCeIGlx2ivFIJp3XYdMfX60Msv0HGDrb0LPjvxTtdOXzHnzM/whFXI
P0/KlRk2HOKSBubj7Qdc4bksLtlFxKpXIb8DZ+Fh7g+9Nck9NAxi0k0S+ENYZrKK
N9yqhemx96wfq2jQ9lxrN2VUsinmzg4PTPvVsV0C2oasYojHI+MgfEf4v90Uexcp
ICtS1QSTNIoZBkkldsDuafFbM8pUb+A9Lk4g4qsreO7WxiRwJLlhkRgk7/littKl
FurZghN85TSukNcabbXM8Fr5KS3FvkPdY35M7fU0WLH8kq+h2fyPhx8l3IIiABgd
BXXo8zdmt8UZCeGpdBHtUQ95qhAd4t0qS40u5khuXjRV53hxkPg5+lZMmGLbmjpY
/LmofDLaBjS7oTXHKhJ9CVyD7VypKjqQlaDPRrFLgqWwI8bKB+tqQ0aOV7QTwQGF
G8hUMgX4ckgUH9DFvsk3ViDYvzElnXlNOxqnbLb2ckeLHgHqV/xGdUttevbG1hYy
J92uHieM57Mpxt71pUfoa3HjUgU4h4j1rhG1LyXVzOY1Cmd8FmIA3YDABPXIquCb
M7yNdMVXGWqcWeIKPZRC7gtZFDSzElHkH/EEdF7nff8AKmxjGBmyTll0Gngr4H6t
ptzCLm/CWQfmFvGWLMR7k4H0FBN+6NeJKKpM6sTQnsrGOW3zlBg7YyPWuZku7NCe
zE6gsyeVzAFsjm5e/wCsUKZTQNcSadlWAIVSvVd8Y9PenRTRkcgA1BvIkKAAu+FB
C4BPr+vStMVsyzlSYScBcJ3ev+fcWWqNprW7KjAR84YEdN66CwLMtuqOfHyn4z0r
scGjaXHo9p5QleeU7yTyH4nPqa348ccaqJzs2aWeXKROMm1Oozmp3q6IWAJoBpkP
nUIe7etAQ1XsS3FlcRHfnjYY+lU1ZadMU9vdtbzJgKMNhWB3Prnb2riSXo7qfsYn
DmpRSQqQQT6Mfn0rJPs243a0FMGtQ28RDMiKmA3M2D9akVzdDZfijRdcUQ80uOUo
uwYH8RrWopdi1OwJ4j1ePVBLEHRYzkFOU8x7DtjrmnpJbETnKekAHGnCcGruqzRA
xthCG/CMdwMd/wBYrNKW6Q2EXVm+Tg+yttIIhQYjARSi7Zx/o/yquW7sjT9GnRrh
dGmjjClFiHKOYfChzvv3O/1o5STQMW07QXW/G1vbuI2KNzj4ctnm9tu/5UhxT0aP
kImpeQype20gYZ5XjXsc7H5dqzThxehkZ8kUWvajHLZOV25F+Is2CfTB6UzGZsuh
c6jexX06gZVyc7jICn/dbYqjBJ3ocXhDbhOGZrjlwbi4Y57kKAo/vXYwKoHHzu5h
tWgzGWBRkMGqEJxegDPPM9/yqqJZ95lUSzzzfcVCWKnWYlsdSuUY8gSXB+RO23yN
cTNHjNo7mF8oJlxwrqAW58oElC2ME9PbFZJo14pbottX1oWy/DKvI6MmHwAvbOeu
diaOK4xKnNykDGj31pLcow1BAsezuZMEHv07Y7UalJhRj6LmDifhWwdZFvDdzKxI
EZLcpPXH5VKbNccT+jXc+JnDTXItru2ZIQoxykHPqaF422aVj1plNqvj5w/b+Zp2
m2DPCv8A8k9zKq84HoBV8H6GfAquTBPU/GDhO5TyJ1FlKMEZOUz26VXBmWWKugeh
490i/vWsrLUYJZSTImWAY75wKHjJbZkkvQW6brxZnjklZUkTOM/hJO4OOm+Pr86C
UbRUZUwe4v11kCRZiDsen4tt8467dKZij7FZpVoFpL1YVYseg69Bv1/IU9dmZh/w
/wDaF4O4I0aw0PVNQitr+3iHnRlwCGO52+tdmDUYpHGnuTsvLb7T/AFzJyDWrcH/
APoKZyQFBRpXi9wnrQH3bWLdif8AvFEmiqCGDWbG8UNDeQyA9MOKIlMsjMMdaGiz
EzYqUQxM1UQ8aU1CANx9beRdw33LmKTCuc9GHT+Y/pXO8qHUzoeLPTgUmkX72t7H
KAAQSoB9Pf1zXOkrR0E6dlvrGiwcRzxRxySCAgGRB/Ee/wAqRJ1o0RqTtFdqn2e+
F0heZbWW3lkOZJIJpIy3zweg9cU/HJLUjdHRVRfZ54Vm54TeaxAz52XVJuX58oat
dRZpjJ/RruPsn6PLbMLLiXU7FQCCy3PmDJO2OcNv8qFxX2O5pdxK2f7J3Bmkof2t
qWpak4OMTXjDOM9FUqBt7d6qkuyr5dRKPUvAXw7tVzHoUK56PJPIST8i29C2kKmk
E3DngtwtpkBuotFs7WTlyCsQDb7bnv8AKsWXI3pGd01SRGvdLi0iVYgSFX4/gOSf
b5e9DFt9mN66F3rN+8l07cvI7KcIdsHPT5da2RVIwSdvZUWMk2sa1a2LMXHmB3IG
Bjbb5bUxaVg7k+IEeLPCnD+r+IOsW14oguwwIlVtzkbV0MaUoIw5lWRim1vwk1Ky
lZ9OmW8j6qOjYq3B+hAH3Emo6HcmKcS2ky+5U0DtEL3S/FDibSQv3TW72Hl6ATEj
86vk0VSP1uD5FbxZ7zZFAQ+zmoQ95qhCHrGmx6tpk9tLsrrsw6qR0IoJxUotMKEn
GSaFM8ksDPEV/fxMQQMb47gnoK4T0d3+wq4T1hIHWXcSklWHNgbD0/nSJIZB00Gi
6wt1bupGR0XB/F8/SlpnR00A/EDahYq7WE7xMQTysAQT679KbHJRFKUXaFrqviNx
hp9ysUUcEyDcu7sPr1NOTv2O/wAqa04FeOKuN9fybp4LVOoMamRuvq2386ptIr/J
yS0kkEuh6bIJlluJXupxsXmbmx8qzynYLt/swputc8q3KN8e34cf1pXbKelYCcUc
Q80D5D+YBldgm/8Aj3NaIxs5+STTFLqmqx21q0zMJFY4BQZDbf3Oa1JX0Y5Ouwq8
JtGaeRtQlUq0m6j/AIqOgpWSXpD8MP8AZiO+01KdJ8Zb1lDp5tvDL167EVvxuoo5
3kKsrIXDnGLlU535go6N1NalKzOWuuadYcX2ZjvIVMnLlJY/xLRPfYAluIOFb/h6
6dHjZ4QfhkUbEUlxaIfsEtbxRmDigIZA1CFZrPEun6DA0t3cImN8Z3qNkSsR3HX2
uOH+H2kgtplmlXYrF8Rpbmgki+N0Nd0qz1a3UNJNGJQv/IHciuLLto9BxtJosNCu
obvyzBIIwTzOpzt7E9velNMWmMOxtGu4AwVCSOZmDY5fnnt70lxNsMln2o8Ny3QZ
l6YxjJIyKV7NCaBd/D+W4klL24SVW5QgbPbYn0+VMVoO09GgcBSWbFpJzGq/iGPx
EnbPsKjuRP1LO24OeN1AlEa5wOXfJxtnpikO7LtMo+JbGK3B5GDoCPNUDPKPUkHb
PvWiMWZMkndCo8SHg062ZufmkZ/xNkDGM5+oHrWiCMM3oWOkWMnFmtKjEtbA5IXo
QDn/AFTZPghcI85HQXDOkpp9rEiryoqgBRvXP5WzrRjSOWPtpaabPjnRdSA+C6sz
EW/7kb/Brq4HcaOL5kampCe4f1BiACdyetaU9mEYFnqDK6qrMFC9Af704lE1nF9G
ElUPGevNRIFn6RA4rSJKjX+LtO4bt2lvLhUwM4JqnSIkc8+JX2vbHS/NttKP3mYZ
GIjsPmaTKaDSOXOPvHfiPjF5Enu2t7dv+nEx3HuaQ5NhCze7eUlVJZm2wOpoSH6A
/Z+1STW/CfRGn3uIIvKYE77bVzsqamd3A+eJMudSlk4e1FbyNf3Ekg85B2/7hVxq
WhWRcfyQwuGeKfMUKoMNtyZYRnIZSNyPfcf1qmioyC6LiwNOcSK0JA5OYnJx3G+D
/wDtKpGuEj7VOI7WIKV5Q7NyuXzn/fpn1oW0+jR1sqJeIoHM1xC/mgR5AZcBTnvn
+VUiOS9lVfcZLEuWAVi255yFyd8jHcZFVVgSkAOu8R8rPIzB2Vgx32YDfc96dFGS
WhAeI3GUmu63LptuwMEZ/eNzZ5fRR71oUaVsyOXJjC8LOHPucEc8ylHkGeQfw/7/
AM1hzSt6OngjURu2MDQ2uGbnOScgYwPSsyezY1QjPtScGHjLhOB4v/t2MhkiPrtu
K3YsnBnP8jD8sKXZx7pUM9pJ5cilJEfBBro2ntHDprTDfT7jMZOTnGMCnRKLa2uF
MeFbB6HB60ZDsTxW+0fpHBVvJDDOJLjBCohyxPyp8ppCVE4x8R/GzXOPryQTTvb2
hO0KN1HuazOTkHQubi8KrjmoCG3QNBuuJb0RplYgfierirIHz8MaVw1aZwJbjH4j
vvTaUSDz+ypxmt9HqujO4DxMJY19jXO8hW0zreFLTiPvVLNby3YMoO2DnoKyJ0bJ
xsCG1WfhBiZA0tgpwGG3leoz2Hv9K0L8jE04f0SYvEBQjLGyOr4Y8zBQuB2+X96p
w9hwmQNR8UbeJ4ybg8/QA7gHPTr09TQrGPeZEe68ZLGW2cffI/i/hVgcZG/z6VXx
tBfNHYGa74yWT+a8c3MhXGwIzue3UUaxszyzr0AWu+LMmoILbTkcuCQHBPKd+pH9
qao12ZnNzJ/hnwdNfXy3N1k5cyMzblm6nNIyzpUacOJyezpDhvSxbxIqKVVep9BX
OkzrRSiXt1ckARxYx3oEE9gL4hJzaYyEZOQcU9bFPo468Q9F/ZPEskiLiKVubAro
4ZWqON5MOMrRXW0pUqd+U9hW1HPLa3lPKxVVKE4zncfSjTIz/9k="

    result_xml += "  <User>
    <Username>#{username}</Username>
    <Password>#{act_code}</Password>
    <Email>#{email}</Email>
    <Name>#{attendee_name}</Name>
    <CreationDate>#{start_date.to_i * 1000}</CreationDate>
    <ModifiedDate>#{modify_date.to_i * 1000}</ModifiedDate>
    <Roster/>
    <vCard xmlns=\"vcard-temp\">
        <VERSION>2.0</VERSION>
        <FN>#{attendee_name}</FN>
        <PHOTO>
            <TYPE>JPG</TYPE>
            <BINVAL>#{photo_u64_data}</BINVAL>
        </PHOTO>
    </vCard>
  </User>
"
  end
  result_xml += "</Openfire>\n"
  
  result_xml
end


def make_temp_dir()
#  shared_temp_fldr = Dir.tmpdir
  shared_temp_fldr = File.join(rails_root_fldr, 'tmp' )
valid_chars = ("A".."Z").to_a + ("a".."z").to_a + ("1".."9").to_a

  is_unique = false
  until is_unique
    unique_dir = 'f2n_'
    10.times do
      unique_dir << valid_chars[ rand(valid_chars.size-1) ]
    end

    full_unique_dir = File.join( shared_temp_fldr, unique_dir)
    is_unique = ! ( File.directory? full_unique_dir )
    
    # try again if the directory already exists.
    if ! is_unique
      print 'make_temp_dir:' , unique_dir,'already exists. Trying another combination.',"\n"
    end
  end # until is_unique
  
  FileUtils.mkdir_p( full_unique_dir )
  raise "Unable to make temporary folder at '"+full_unique_dir+"'" unless File.directory? full_unique_dir
  
  return full_unique_dir
end


# Runs a shell script, and returns: [output]
# Raises an error if the command returned a non-zero exit status.
def run_cmd( cmd, error_msg="Executing shell command" )
  output = %x[ #{cmd} ]  # run the command
  
  # check for errors
  status = $?.exitstatus
  if status != 0
    raise "#{error_msg}. COMMAND=>>>#{cmd}<<< EXIT_STATUS=#{status} OUTPUT=>>>#{output}<<<"
  end

  return output

end

def tar_gz( event_name, output_dir, tarball_source )
  # Create filename
  date_str = Date.today.strftime("%Y-%m-%d")
  event_md5 = Digest::MD5.hexdigest(event_name).slice(0,5)
  raise "Assert md5 truncated to 5 chars" unless event_md5.length == 5
  tarball_filename = File.join( output_dir, "face2name-config-bundle-#{date_str}-#{event_md5}.tar.gz" )
  filenames_to_tar = File.join( output_dir, "filenames_to_tar.txt" )
  
  # Make list of files to import
  f = File.new( filenames_to_tar, 'w' )
  Find.find( tarball_source ) do |path|
    if path != tarball_source # skip listing of the folder itself
      path[0..tarball_source.size] = ""  # remove folder
      f.write( path +"\n")
    end
  end
  f.close()
  
  # compose command line to run
  tar_gz_cmd = "/usr/bin/tar -czf \"#{tarball_filename}\" -C \"#{tarball_source}\" -T #{filenames_to_tar} 2>&1" # 2>&1 will capture stderr
  output = run_cmd( tar_gz_cmd, "Trying to tar-gzip file, but the command failed." )

  if ! File.exists? tarball_filename
    raise "Problem creating configuration bundle. tar/gzip command seemed to work, but there is no output file. COMMAND=>>>#{tar_gz_cmd}<<< OUTPUT=>>>#{output}<<<"
  end
  
  return tarball_filename
end

#
# Make server key and CSR
# see: {svn}/face2name/tests/openfire/extract.sh
#
def openssl_certificates( temp_dir, keys_dir, cert_serial_num, event_name, not_before, not_after )
#  raise "not_before should be a Time object but is #{not_before.class.name}."\
#    unless not_before.respond_to? Time
#  raise "not_after should be a Time object but is #{not_after.class.name}." \
#    unless not_after.instance_of? Time

  # output files:
  ssl_server_cert = File.join(keys_dir, "f2n_server.cert")
  ssl_server_key  = File.join(keys_dir, "f2n_server.key")
  f2n_server_csr  = File.join(keys_dir, "f2n_server.csr")
  # temporary files:
  openssl_config  = File.join(temp_dir, "openssl.cnf")

  # input files needed:
  lib_fldr = File.join( rails_root_fldr, 'lib' )
  ssl_config_template = File.join( lib_fldr, 'openssl.cnf.tmpl')
  # ssl_ca_cert and ssl_ca_key should be the same files used to configure your server, i.e. passed to "extract.sh"
  ssl_ca_cert = File.join( lib_fldr, 'f2n_ca.crt' )
  ssl_ca_key =  File.join( lib_fldr, 'f2n_ca.key.unsecure' )

  # Check needed input files are there
  for f in [ssl_config_template, ssl_ca_cert, ssl_ca_key]
    if ! File.exists?( f )
      raise "Could not find required file to generate event certificate: '#{f}'"
    end
  end

  # create 'keys' folder if needed
  if ! File.exists? keys_dir
    FileUtils.mkdir( keys_dir )
  end

  # compute_subject_alt_name
  subject_alt_name = Digest::SHA1.hexdigest( event_name )+'.sha1.f2n-server-cert.face2name.local'

  # modify ssl config template
  config = File.open( ssl_config_template, 'r' ).read()
  config.gsub!( '@SUBJECT_ALT_ENABLED@', "" )
  config.gsub!( '@SUBJECT_ALT_NAME@', subject_alt_name )
  config.gsub!( '@CN@', event_name )
  f = File.new( openssl_config, 'w' )
  f.write( config )
  f.close()

  # Generate key
  run_cmd( "openssl genrsa -out \"#{ssl_server_key}\" 1024  2>&1", #>/dev/null 2>&1",
    "Server key generation failed" )
#         openssl genrsa -out "${SSL_SERVER_KEY}" 1024 >/dev/null 2>&1
#         check_error "Server key generation failed"

  run_cmd( "openssl req -config \"#{openssl_config}\" -new -key \"#{ssl_server_key}\" -out \"#{f2n_server_csr}\" 2>&1",
#  run_cmd( "openssl req -config \"#{openssl_config}\" -new -key \"#{ssl_server_key}\" -out \"#{f2n_server_csr}\" >/dev/null 2>&1",
    "Server CSR generation failed" )
#         openssl req -config "${conf}" -new -key "${SSL_SERVER_KEY}" -out "${path}/f2n_server.csr" >/dev/null 2>&1
#         check_error "Server CSR generation failed"


  # Sign server cert
  days = ((not_after - Time.now()) / (60*60*24)).ceil # Convert seconds to days
  f2n_serial = File.join( lib_fldr, 'f2n.serial' )
  cmd = "openssl x509 -req -extfile \"#{openssl_config}\" -extensions \"usr_cert\" "+
      "-in \"#{f2n_server_csr}\" -CA \"#{ssl_ca_cert}\" -CAkey \"#{ssl_ca_key}\" "+
      "-out \"#{ssl_server_cert}\" -days #{days} -CAcreateserial "+
      "-set_serial #{cert_serial_num} 2>&1"
#      "-CAserial \"#{f2n_serial}\" 2>&1"
  run_cmd( cmd, "Certificate signing failed")
#         openssl x509 -req -extfile "${conf}" -extensions "usr_cert" -in "${path}/f2n_server.csr" -CA "${SSL_CA_CERT}" -CAkey "${SSL_CA_KEY}" -out "${SSL_SERVER_CERT}" -days 365 -CAcreateserial -CAserial "${path}/f2n.serial" >/dev/null 2>&1
#         check_error "Certificate signing failed"

  return ssl_server_cert
end



#
# Run the f2n-cipher Java program to encrypt our tarball.
#
def f2n_cipher( tempdir, tgz_filename )

  cipher_fldr = File.join( rails_root_fldr, "f2n_scripts", "f2n-cipher-1.0.0/" )
  cipher_jar = File.join( cipher_fldr, "f2n-cipher-1.0.0.jar" )
  pub_key = File.expand_path( File.join( cipher_fldr, 'keys', 'f2n_config_bundle_enc.key' ) )

  if ! File.exists? cipher_jar
    raise "Could not find encryption script f2n-cipher. Expected it at: #{cipher_jar}"
  end
  if ! File.exists? pub_key
    raise "Could not find encryption key for f2n-cipher. Expected it at: #{pub_key}"
  end

  output_filename = tgz_filename +'.cipher'

  cmd_cipher = "cd #{cipher_fldr}; java -jar #{cipher_jar} -e #{tgz_filename} -r #{output_filename} -p #{pub_key}"

  output = run_cmd( cmd_cipher, "Trying to encrypt the configuration bundle." )

  if ! File.exists? output_filename
    raise "Tried to encrypt the configuration bundle and it returned a good exit code, but the file is missing."
      +"COMMAND=>>>#{cmd_cipher}<<<< OUTPUT=>>>#{output}<<<"
  end

  return output_filename
end


def make_configuration_bundle( cert_serial_num, event_name, attendees, admin_pass, not_before, not_after )

  # build directory structure on disk
  tempdir = make_temp_dir()
  tarball_source = File.join( tempdir, 'to_tar_gz' )
  FileUtils.mkdir_p( tarball_source )
  raise "Assert: Unable to make temporary folder at '"+tarball_source+"'" unless File.directory? tarball_source

  # Get list of photos
  # TODO [ww may 2010]

  openssl_certificates( tempdir, File.join( tarball_source, 'keys' ),
    cert_serial_num, event_name, not_before, not_after )

  # Make XML file
  if attendees!=nil and attendees.length > 0
    f = File.new( File.join(  tarball_source, 'users.xml'), 'wb' )
    f.write( make_users_xml( attendees ) )
    f.close()
  end

  # Make admin password File
  f = File.new( File.join(  tarball_source, 'admin_password.txt'), 'wb' )
  f.write( admin_pass )
  f.close()

  # tar/gzip it.
  tgz_filename = tar_gz( event_name, tempdir, tarball_source )

  # encrypt it
  cipher_filename = f2n_cipher( tempdir, tgz_filename )

  return [cipher_filename, tempdir]
end

def cleanup( tempdir )
  raise "The directory 'to_tar_gz' does not exist. Can't be an old configuration bundle temp folder."\
    unless File.exists? File.join( tempdir, 'to_tar_gz')
  FileUtils.rm_rf( tempdir )
end
