#import "template.typ": *
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
      location: [Riga, Latvia],
      email: "sergejs.umnovs@edu.rtu.lv"
    ),
  ),
  index-terms: ("vilnius oscillator", "image encryption", "chaos"),
  bibliography-file: "refs.bib",
)

= Introduction

Image encryption is a common process in modern communication and storage systems. It is used to protect confidentiality and integrity of digital images from unauthorized access. Considering the omnipresence of visual data, it's processing takes a considerable amount of compute resources. Chaos-based image encryption supposedly provides a higher data rate and compute efficiency than traditional image encryption methods. In this paper, a simple chaotic system is used@vilnius-osc-origin as a pseudo-random number generator. A bitstream produced by the generator is then used to diffuse the pixel data of the plain image, resulting in a cipher image. The result of this research is a VHDL model that implements both the Vilnius oscillator and the image encryption process.

= Methods

Chaotic sequences that are required for encryption are produced using a pair of Vilnius oscillators that produce values $x_k$ and $y_k$, where $k$ is an index of a sample of oscillator readings.  These values are then used to produce a single random bit comparsion, as shown in formula @prng-function.

$ f(x_k, y_k) = cases(
  1 "if" x_k >= y_k,
  0 "if" x_k < y_k
) $ <prng-function>

The PRNG bit is then used to transform 

#figure(
  image("figs/chaos-encryption-scheme.drawio.svg")
)

== Vilnius oscillator



= Results

= Conclusion