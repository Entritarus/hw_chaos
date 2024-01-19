#import "template.typ": *
#import "@preview/codelst:2.0.0": sourcecode

#show: ieee.with(
  title: [Chaotic sequences based image encryption],
  abstract: [
     In this paper we propose an image encryption method based on chaotic sequences produced by a pair of Vilnius oscillators. The solution is provided as a VHDL model and is tested against implementation in Matlab. 
  ],
  authors: (
    (
      name: "Kirill Trofimov",
      department: "Institute of Radioelectronics",
      organization: "Riga Technical University",
      location: [Riga, Latvia],
      email: "kirils.trofimovs@edu.rtu.lv"
    ),
    (
      name: "Sergej Umnov",
      department: "Institute of Radioelectronics",
      organization: "Riga Technical University",
      location: [Riga, Latvia],
      email: "sergejs.umnovs@edu.rtu.lv"
    ),
  ),
  index-terms: ("vilnius oscillator", "image encryption", "chaos"),
  bibliography-file: "refs.bib",
)

= Introduction

Image encryption is a common process in modern communication and storage systems. It is used to protect confidentiality and integrity of digital images from unauthorized access. Considering the omnipresence of visual data, it's processing takes a considerable amount of compute resources. Chaos-based image encryption supposedly provides a higher data rate and compute efficiency than traditional image encryption methods. In this paper, a simple chaotic system is used@vilnius-osc-origin as a pseudo-random number generator. A bitstream produced by the generator is then used to diffuse the pixel data of the plain image, resulting in a cipher image. The result of this research is a matlab and VHDL model that implements both the Vilnius oscillator and the image encryption process.

= Methods

Chaotic sequence that is required for encryption is produced by Vilnius oscillator. When oscillators function crosses $Y=0$, related $X$ value is compared to an arbitrarily chosen threshold as in formula @threshold-comp. 

$
cases(
  1 "if" x < 60 and y = 0,
  0 "if" x >= 60 and y = 0
) 
$ <threshold-comp>

Bitstream generation method is shown in @method.

#figure(
  image("figs/method.jpg"),
  caption: [Bitstream generation method]
) <method>

== Vilnius oscillator

Study depends on the Vilnius oscillator@vilnius-osc-origin as a chaos oscillator to generate PRNG sequences. Circuit diagram of the Vilnius oscillator is given in @circuit. 

#figure(
  image("figs/circuit.jpg", width: 70%),
  caption: [Vilnius oscillator circuit diagram @vilnius-osc-origin]
) <circuit>

A system of equations that defines the Vilnius oscillator is shown in @system @vilnius-osc-origin.

$ cases(
  C_1 (dif V_C_1) / (dif t) = I_L,
  L (dif I_L) / (dif t) = (k - 1)R I_L - V_C_1 - V_C_2,
  C_2 (dif V_C_2) / (dif t) = I_0 + I_L - I_D
) $ <system>

Which is then presented in a more convinient form for simulation in @eq @vilnius-osc-origin.

$ cases(
  accent(x, dot) = y,
  accent(y, dot) = a y - x - z,
  epsilon accent(z, dot) = b + y - c(exp z - 1)
) $ <eq>

Constants used for simulation are following:

#grid(columns: 2, gutter: 10pt)[
  $R_1 = 1 dot 10 ^ 3 ohm$
][
  $R_2 = 10 dot 10 ^ 3 ohm$ 
][
  $R_3 = 6 dot 10 ^ 3 ohm$ 
][
  $R_4 = 20 dot 10 ^ 3 ohm$ 
][
  $C_1 = 1 dot 10 ^ (-9) "F"$
][
  $C_2 = 150 dot 10 ^ (-12) "F"$
][
  $L = 1 dot 10 ^ (-3) "H"$
]

== FPGA simulation



#figure(
  image("figs/fpga_sim-vs-matlab_sim.jpg"),
  caption: [FPGA simulation compared to Matlab simulation]
) <fpga-vs-matlab>

== Exponent approximation

The need to approximate the exponent function on FPGA arises from the fact that the exponential function is computationally expensive and requires a large number of resources to compute accurately. Follwing is the representation of exponent approximation in matlab:

#sourcecode(
  frame: none
)[```matlab
function value = exp_approx(x, N, x_min, x_max)
  x_step = (x_max-x_min)/N;
  value = 0;
  for i = 0:N-1
    x1 = x_min + i*x_step;
    x2 = x1 + x_step;
    if x >= x1
      y1 = exp(x1);
      y2 = exp(x2);
      value = (x-x1)/(x2-x1)*(y2-y1) + y1;
    end
  end
end
```]

#figure(
  image("figs/expo-approx.jpg"),
  caption: [Difference between approximated exponent and $e^x$]
) <expo-approx>

= Results

While generally the source images are encrypted, nonuniform distribution is clearly visible, especially in @cameraman, where the dark region has impact on the same region in the resulting image. 

#figure(
  grid(
    columns: 2,
    gutter: 1pt,
    image("figs/cameraman.jpg"),
    image("figs/cameraman_encr.jpg"),
  ),
  caption: [Cameraman: plain image, cipher image]
) <cameraman>

#figure(
  grid(
    columns: 2,
    gutter: 1pt,
    image("figs/jetplane.jpg"),
    image("figs/jetplane_encr.jpg"),
  ),
  caption: [Jetplane: plain image, cipher image]
) <jetplane>

#figure(
  grid(
    columns: 2,
    gutter: 1pt,
    image("figs/livingroom.jpg"),
    image("figs/livingroom_encr.jpg"),
  ),
  caption: [Livingroom: plain image, cipher image]
) <livingroom>

= Conclusion