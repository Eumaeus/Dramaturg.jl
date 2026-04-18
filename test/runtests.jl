using Dramaturg
using Test

@testset "Dramaturg.jl" begin
    @test Dramaturg.version() isa VersionNumber
    # Add more tests as we build functions
    println("✅ All tests passed (skeleton)")
end