transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+C:/Users/song_/Desktop/Code/Digital\ Audio\ Visualizer/FFT {C:/Users/song_/Desktop/Code/Digital Audio Visualizer/FFT/butterfly.sv}
vlog -sv -work work +incdir+C:/Users/song_/Desktop/Code/Digital\ Audio\ Visualizer/FFT {C:/Users/song_/Desktop/Code/Digital Audio Visualizer/FFT/fft_top.sv}
vlog -sv -work work +incdir+C:/Users/song_/Desktop/Code/Digital\ Audio\ Visualizer/FFT {C:/Users/song_/Desktop/Code/Digital Audio Visualizer/FFT/fft_tb.sv}

