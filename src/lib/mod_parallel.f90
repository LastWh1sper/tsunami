module mod_parallel

  ! A module to provide parallel facilities 
  ! to the shallow water solver.

  use mod_kinds, only: ik, rk

  implicit none

  private
  public :: tile_indices, tile_neighbors

contains

  pure function tile_indices(dims)

    ! Given input global array size, return start and end index
    ! of a parallel 1-d tile that correspond to this image.

    integer(kind=ik), intent(in) :: dims
    integer(kind=ik), dimension(2) :: tile_indices
    integer(kind=ik) :: offset, tile_size

    tile_size = dims / num_images()

    ! start and end indices assuming equal tile sizes
    tile_indices(1) = (this_image() - 1) * tile_size + 1
    tile_indices(2) = tile_indices(1) + tile_size - 1

    ! if we have any remainder, distribute it to the tiles at the end 
    offset = num_images() - mod(dims, num_images())
    if (this_image() > offset) then
      tile_indices(1) = tile_indices(1) + this_image() - offset - 1
      tile_indices(2) = tile_indices(2) + this_image() - offset
    end if

  end function tile_indices

  pure function tile_neighbors()

    ! Returns the image indices corresponding 
    ! to left and right neighbor tiles.

    integer(kind=ik), dimension(2) :: tile_neighbors
    integer(kind=ik) :: left, right

    if (num_images() > 1) then
      left = this_image() - 1
      right = this_image() + 1
      if (this_image() == 1) then
        left = num_images()
      else if (this_image() == num_images()) then
        right = 1
      end if
    else
      left = 1
      right = 1
    end if

    tile_neighbors(1) = left
    tile_neighbors(2) = right

  end function tile_neighbors

end module mod_parallel
