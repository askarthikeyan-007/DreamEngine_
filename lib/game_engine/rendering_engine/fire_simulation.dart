/// Simulated module for FireSimulation in the Procedural Voxel Renderer layer.
class FireSimulation {
  final int maxShaders = 32;
  bool pipelineCompiled = false;

  void buildPipeline() {
    pipelineCompiled = true;
  }

  void renderMeshBuffers() {
    if (!pipelineCompiled) return;
    // Swap front and back framebuffers
  }
}
