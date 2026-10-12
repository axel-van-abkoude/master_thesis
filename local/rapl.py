from numpy.random import random
from numpy import matmul, vecdot, tensordot, zeros, uint64
from plotly.graph_objects import Figure, Scatter
from time import monotonic_ns

# TODO rapl/core/measure_energy
# TODO rapl/perf/inotify | rapl/perf/os.open
# TODO rapl/devx/setup_on_oserror
def rapl_open() -> File:
	"""
	Open rapl file which contains the energy consumption from boot in micro joules
	NOTE:
	The data relates to the energy consumption of the entire system:
		-> minimize other workload
		-> compare to zero measurement
	"""
	RAPL_PATH = '/sys/class/powercap/intel-rapl:0/energy_uj'
	rapl_file = open(RAPL_PATH, 'r')
	return rapl_file

# TODO rapl/core/measure_energy
# TODO rapl/core/measure_time
# TODO rapl/show/live_dash
def rapl_Xns_Yuj(rapl_file: File) -> Point:
	ns = monotonic_ns()
	uj = rapl_file.read()
	rapl_file.seek(0)
	return (uint64(uj), ns)

def bench(fun, fig, N=500, ITER=100):
	X_ns = zeros(ITER+1, dtype=uint64)
	Y_uj = zeros(ITER+1, dtype=uint64)
	M1 = random((N,N))
	M2 = random((N,N))
	with rapl_open() as rapl_file:
		X_ns[0], Y_uj[0] = rapl_Xns_Yuj(rapl_file)
		for i in range(1,ITER+1):
			M3 = matmul(M1,M2)
			X_ns[i], Y_uj[i] = rapl_Xns_Yuj(rapl_file)
	X_ns = X_ns-X_ns[0]
	Y_uj = Y_uj-Y_uj[0]
	fig.add_trace(Scatter(x=X_ns, y=Y_uj, name=fun.__name__))

def run():
	fig = Figure()
	for fun in [matmul, vecdot, tensordot]:
		bench(fun,fig)
	fig.update_layout(
		title=dict(
			text='System Energy Consumption over time'
		),
		xaxis=dict(
			title=dict(
				text='Time (ns)'
			)
		),
		yaxis=dict(
			title=dict(
				text='Energy (uj)'
			)
		),
	)
	fig.show()

# TODO rapl/show/deque
# TODO rapl/show/live_dash
# def rapl_dash():

# TODO rapl/devx/types
# type ns = uint64
# type uj = uint64
# type Frame = tuple[deque, deque]

# TODO rapl/devx/class_for_lifetime_rapl_file
# class Rapl(File):
# 	FILE_NAME
# 	fd
# 	def open() -> Rapl:
# 	def read_uj(self) -> int:
# 	def time_ns(self) -> str:
# 	def close(self):

