#include once "QuadraticEquation.bi"
#include once "crt.bi"

Function SolveQuadraticEquation( _
		ByVal a As Double, _
		ByVal b As Double, _
		ByVal c As Double, _
		ByVal pRoot2D As Root2D Ptr _
	)As QuadraticEquationStatus
	
	If a = 0.0 Then
		pRoot2D->X1 = 0.0
		pRoot2D->X2 = 0.0
		Return QuadraticEquationStatus.NoSolution
	End If
	
	Dim Status As QuadraticEquationStatus = Any
	
	Dim d As Double = b * b - 4 * a * c
	
	Select Case d
		Case Is < 0.0
			Status = QuadraticEquationStatus.ComplexRoots
			
		Case 0.0
			Status = QuadraticEquationStatus.OneRoot
			
		Case Else
			Status = QuadraticEquationStatus.TwoRoots
			
	End Select
	
	Dim Discriminant As Double = fabs(d)
	
	pRoot2D->X1 = (-1.0 * b + sqrt(Discriminant)) / (2.0 * a)
	pRoot2D->X2 = (-1.0 * b - sqrt(Discriminant)) / (2.0 * a)

	Return Status
	
End Function
