#version 300
#extension GL_ARB_compute_shader : require
#extension GL_ARB_separate_shader_objects : require
layout(local_size_x = 256, local_size_y = 1, local_size_z = 1) in;

struct Particle
{
    vec2 position;
    vec2 velocity;
};

struct ParticleForces
{
    vec2 acceleration;
};

layout(std140) uniform type_cbSimulationConstants
{
    float timeStep;
    float wallStiffness;
    vec4 gravity;
    vec3 planes[4];
} cbSimulationConstants;

layout(std430) buffer type_RWStructuredBuffer_Particle
{
    Particle _m0[];
} particlesRW;

layout(std430) readonly buffer type_StructuredBuffer_Particle
{
    Particle _m0[];
} particlesRO;

layout(std430) readonly buffer type_StructuredBuffer_ParticleForces
{
    ParticleForces _m0[];
} particlesForcesRO;

void main()
{
    vec2 _51 = particlesRO._m0[gl_GlobalInvocationID.x].position;
    vec2 _53 = particlesRO._m0[gl_GlobalInvocationID.x].velocity;
    vec2 _57;
    _57 = particlesForcesRO._m0[gl_GlobalInvocationID.x].acceleration;
    for (uint _60 = 0u; _60 < 4u; )
    {
        _57 += (cbSimulationConstants.planes[_60].xy * (min(dot(vec3(_51, 1.0), cbSimulationConstants.planes[_60]), 0.0) * (-cbSimulationConstants.wallStiffness)));
        _60++;
        continue;
    }
    vec2 _84 = _53 + ((_57 + cbSimulationConstants.gravity.xy) * cbSimulationConstants.timeStep);
    particlesRW._m0[gl_GlobalInvocationID.x].position = _51 + (_84 * cbSimulationConstants.timeStep);
    particlesRW._m0[gl_GlobalInvocationID.x].velocity = _84;
}

