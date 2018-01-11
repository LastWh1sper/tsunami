program tsunami

! Tsunami simulator
!
! This version solves the linearized 1-d advection equation:
!
!     du/dt + c du/dx = 0
!
! Discretized as:
!
!     u^{n+1}_i = u^n_i - c * dt * (u^n_{i} - u^n_{i-1}) / dx

use iso_fortran_env, only: int32, real32, output_unit

implicit none

integer(kind=int32) :: i, n

integer(kind=int32), parameter :: im = 100 ! grid size in x
integer(kind=int32), parameter :: nm = 100 ! number of time steps

real(kind=real32), parameter :: dt = 1 ! time step [s]
real(kind=real32), parameter :: dx = 1 ! grid spacing [m]
real(kind=real32), parameter :: c = 1 ! phase speed [m/s]

real(kind=real32), dimension(im) :: du, u

! initialize a gaussian blob centered at i = 25
do i = 1, im
  u(i) = exp(-0.02*(i-25)**2)
end do

! write initial state to screen
write(unit=output_unit, fmt=*) 0, u

time_loop: do n = 1, nm

  ! apply periodic boundary condition on the left 
  du(1) = u(1) - u(im)

  ! calculate the upstream difference of u in x
  do concurrent (i = 2:im)
    du(i) = u(i) - u(i-1)
  end do

  ! compute u at next time step
  do concurrent (i = 1:im)
    u(i) = u(i) - c * du(i) / dx * dt
  end do

  ! write current state to screen
  write(unit=output_unit, fmt=*) n, u

end do time_loop

end program tsunami
