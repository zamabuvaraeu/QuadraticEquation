#ifndef QUADRATICEQUATION_BI
#define QUADRATICEQUATION_BI

Enum QuadraticEquationStatus
	TwoRoots
	OneRoot
	ComplexRoots
	NoSolution
End Enum

Type Root2D
	X1 As Double
	X2 As Double
End Type

Declare Function SolveQuadraticEquation( _
	ByVal CoefficientA As Double, _
	ByVal CoefficientB As Double, _
	ByVal CoefficientC As Double, _
	ByVal pRoot2D As Root2D Ptr _
)As QuadraticEquationStatus

#endif
